{filter, find, map, pairs-to-obj} = require \prelude-ls
{create-class, create-factory, DOM:{div, span}}:React = require \react
{find-DOM-node} = require \react-dom
AceEditor = create-factory require \./AceEditor.ls
{debounce} = require \underscore
{compile-presentation-sync}:pipe-web-client = (require \../../index.ls) "", ""

module.exports = create-class do

    display-name: \Example

    # get-default-props :: a -> Props
    get-default-props: -> 
        # width :: Int
        # height :: Int
        # language-abbr :: String
        languages: [] # :: [{abbr :: String, title :: String, initial-content :: String, compile :: String -> String}]
        style: {}

    # render :: a -> VirtualDOMElement
    render: -> 
        selected-language-abbr = @props.language-abbr

        ace-mode = match selected-language-abbr
            | \ls => \livescript
            | \js => \javascript
            | \babel => \javascript
            | _ => selected-language-abbr

        div do 
            class-name: \example
            style: @props.style

            # TITLE
            div class-name: \title, @props.title

            # DESCRIPTION
            div class-name: \description, @props.description

            # CONTENT
            div do 
                class-name: \content,

                # TAB CONTAINER
                div class-name: \tab-container, 

                    # TABS (one for each language)
                    div class-name: \languages,
                        @props.languages |> map ({abbr, title}) ~> 

                            # TAB
                            div do 
                                key: abbr
                                class-name: if abbr == selected-language-abbr then \selected else ''
                                on-click: ~> 
                                    @props.on-language-abbr-changed abbr
                                    
                                "#{title}#{if abbr == selected-language-abbr then ' - live editor' else ''}"

                    # CODE EDITOR
                    AceEditor do 
                        editor-id: @props.title.replace /\s/g, '' .to-lower-case! .trim!
                        class-name: \editor
                        width: @props.width
                        height: @props.height
                        mode: "ace/mode/#{ace-mode}"
                        value: @state[selected-language-abbr]
                        on-change: (value) ~> 
                            <~ @set-state {"#{selected-language-abbr}" : value}
                            @debounced-execute!
                        commands: 
                            * name: \execute
                              exec: ~> @execute!
                              bind-key:
                                  mac: "cmd-enter"
                                  win: "ctrl-enter"
                            ...

                # ERROR (compilation & runtime)
                if !!@state.err
                    div do 
                        class-name: \error
                        style:
                            width: @props.width
                        @state.err

                # presentation
                else
                    div do 
                        class-name: \presentation
                        style: 
                            width: @props.width
                        ref: \presentation

    # get-initial-state :: a -> UIState, 
    # where UIState :: {selected-language-abbr :: String, js :: String, ls :: String, babel :: String, ...}
    get-initial-state: ->
        @props.languages 
            |> map ({abbr, initial-content}) -> [abbr, initial-content]
            |> pairs-to-obj
            |> ~> it <<< 
                selected-language-abbr: @props.language-abbr

    # execute :: a -> Void
    execute: !-> 
        <~ @set-state err: undefined

        view = find-DOM-node @refs.presentation
            ..innerHTML = ""

        [err, f]? = compile-presentation-sync do 
            @state[@props.language-abbr]
            match @props.language-abbr
                | \ls => \livescript
                | \js => \javascript
                | _ => @props.language-abbr
        
        if !!err 
            @set-state err: "COMPILATION ERROR : #{err.to-string!}"

        else
            try 
                [data, presentation-function] = f!
                presentation-function view, data, {x: 1, y: 1} # dummy params for testing
            catch err 
                @set-state err: "EXECUTION ERROR : #{err.to-string!}"

    component-did-update: (prev-props) !-> 
        if prev-props.language-abbr != @props.language-abbr
            @execute!

    # component-did-mount :: a -> Void
    component-did-mount: !-> 
        @execute!
        @debounced-execute = debounce @execute, 750 # when typing