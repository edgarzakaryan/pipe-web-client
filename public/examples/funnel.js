_ => {
  // Data structure required by funnel
  // data :: [{name :: String, size :: Number}]
  const data = [
    {
      name: 'visit',
      size: 1000
    }, {
      name: 'pixel',
      size: 900
    }, {
      name: 'loading',
      size: 800
    }, {
      name: 'ready',
      size: 800
    }, {
      name: 'transition',
      size: 100
    }, {
      name: 'subscription',
      size: 10
    }
  ]

  // the right hand side is what goes in the presentation layer
  const func = plot(withOptions(funnel, {
    margin: {
      top: 0,
      left: 0,
      bottom: 0,
      right: 0
    }
  }))

  return [data, func]
}