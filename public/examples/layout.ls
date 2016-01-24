## this is the data structure required by timeseries
''' 
data :: [{
    type :: String
    y-axis :: Int
    key :: String
    values :: [[Number, Number]]
}]
'''
data = 
  * type: \bar
    y-axis: 1
    key: \square
    values: [0 til 30] |> map -> 
      [Date.now! + (it * 86400000), it * it]
    

  * type: \line
    y-axis: 2
    key: \line
    values: [0 til 30] |> map -> 
      [Date.now! + (it * 86400000), it * 20]
    color: \orange


func = plot layout-vertical do 
    scell do
        0.6
        layout-vertical do 
            cell table
            cell table
    cell multi-chart `with-options` {
        margin:
            left: 80
            right: 80
        x-axis:
            label: \time
            format: (timestamp) -> (d3.time.format '%a %b %d') new Date timestamp
        y-axis1:
            label: \growth
        y-axis2:
            label: \growth
    }

[
    data
    (view, result, parameters) ->
        func view, result, parameters
        <- set-timeout _, 3000 
        func do 
            view
            result |> map ({values}:item) -> 
                {} <<< item <<< values: (values |> take 3)
            parameters
]