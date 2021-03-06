{each, map, id} = require \prelude-ls

module.exports = ({Plottable, d3, plot-chart, nv}:params) ->
    {plotter, options} = (require \./nv-template) params
    new Plottable do
        plotter do
            # RefinedSeries :: {key :: String, values :: [a], color :: String, ...}
            # [RefinedSeries] -> Options -> [ProjectedSeries]
            (refined-series, {x, y}) -> 
                refined-series |> map ({values}:series) -> {} <<< series <<< 
                    values: values |> map -> x: (x it), y: (y it)

            # Map String, NVModel -> NVModel
            (.multi-bar-horizontal-chart)

            # Chart -> DOMElement -> [SeriesWithTrendline] -> Options -> Void
            (chart, , , {show-values, show-controls, stacked}) !->
                chart
                    .show-controls show-controls
                    .show-values show-values
                    .stacked stacked
        
        {} <<< options <<<
            show-values: true
            show-controls: true
            stacked: false
