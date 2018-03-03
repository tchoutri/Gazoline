[
  %Gazoline.Restaurant{
    address: "193 rue Tolbiac 75013 Paris France",
    category: "Bakery",
    fsquare: "555f434e498ec5aedf916407",
    geom: %Geo.Point{
      coordinates: {48.82587853318644, 2.350757839119947},
      srid: 4326
    },
    name: "Brun",
  },
  %Gazoline.Restaurant{
    address: "188 avenue de Choisy (Place d'Italie) 75013 Paris France",
    category: "Snacks",
    fsquare: "4b8010eaf964a5200f4f30e3",
    geom: %Geo.Point{
      coordinates: {48.830418274325034, 2.3566792748646117},
      srid: 4326
    },
    name: "Tang Gourmet",
  },
  %Gazoline.Restaurant{
    address: "204 rue de Tolbiac 75013 Paris France",
    category: "Café",
    fsquare: "4bd1cca9b221c9b6b530d6d0",
    geom: %Geo.Point{
      coordinates: {48.8258019313428, 2.3472279519324353},
      srid: 4326
    },
    name: "Le Circus",
  },
  %Gazoline.Restaurant{
    address: "France",
    category: "Bistro",
    fsquare: "541c258c498e871a2ba69275",
    geom: %Geo.Point{
      coordinates: {48.83051662487893, 2.3548125341451627},
      srid: 4326
    },
    name: "Café O'Jules",
  }] |> Enum.each(&Gazoline.Repo.insert(&1))
