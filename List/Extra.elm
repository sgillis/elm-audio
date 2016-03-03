module List.Extra (zip) where


zip : List a -> List b -> List ( a, b )
zip xs ys =
  case xs of
    [] ->
      []

    x :: xs' ->
      case ys of
        [] ->
          []

        y :: ys' ->
          ( x, y ) :: zip xs' ys'
