defmodule Gazoline.Geo do

  alias Gazoline.{Repo,Restaurant}
  import Ecto.Query
  import Geo.PostGIS
  require Logger
  use GenServer

  @telecom %Geo.Point{coordinates: {48.8263966, 2.3461823}, srid: 4326}
  @category "4d4b7105d754a06374d81259"

  def start_link(client) do
    GenServer.start_link(__MODULE__, client, name: __MODULE__)
  end

  def init(client) do
    Logger.info(IO.ANSI.green <> "[Geo] Starting Geo module" <> IO.ANSI.reset)
    {:ok, client}
  end

  def handle_call({:nth_closests, n}, _from, state) do
    results = Repo.all nth_closests(n)
    {:ok, results, state}
  end

  def handle_cast(:populate, client=state) do
    {lat, long} = @telecom.coordinates
    {:ok, venues} = Bees.Venue.category(client, lat, long, @category, "checkin", 50, 800)
    venues
    |> Enum.map(&venue_to_resto(&1))
    |> Enum.each(&Repo.insert(&1))

    {:noreply, state}
  end

  def nth_closests(n) do
    from restaurant in Restaurant, limit: ^n, select: %{id: restaurant.id, distance: st_distance(restaurant.geom, ^@telecom), name: restaurant.name, category: restaurant.category, address: restaurant.address}, order_by: :geom
  end

  def nth_closests(n, "Asian") do
    from r in nth_closests(n), where: (r.category == "Chinese") or (r.category == "Thai") or
                                      (r.category == "Asian")   or (r.category == "Japanese") or
                                      (r.category == "Vietnamese")
  end

  def nth_closests(n, "Fast Food") do
    from r in nth_closests(n), where: (r.category == "Burgers")   or (r.category == "Doner") or
                                      (r.category == "Fast Food") or (r.category == "Snacks")
  end

  def nth_closests(n, "Café / Bistro") do
    from r in nth_closests(n), where: (r.category == "French")    or (r.category == "Bistro") or
                                      (r.category == "Estaminet") or (r.category == "Café")
  end

  def nth_closests(n, category) do
    from r in nth_closests(n), where: r.category == ^category
  end

  defp venue_to_resto(venue) do
    [cat] = venue.categories |> Enum.filter(fn v -> v["primary"] == true end)

    %Gazoline.Restaurant{
    address: venue.location["formattedAddress"] |> Enum.join(" "),
    category: cat["shortName"],
    geom: %Geo.Point{coordinates: {venue.location["lat"], venue.location["lng"]}, srid: 4326},
    name: venue.name,
    fsquare: venue.id
  }
  end
end
