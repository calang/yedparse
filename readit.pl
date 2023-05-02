/** readit - Read graph information from a yEd graphml file
 * 
 * Extraction of features from a yEd graphml file, using SWI Prolog.
 * 
 * @author Carlos Lang-Sanou
 * 
 */


% Show the parsed structure of the whole graphml file.
dump_graph :-
    load_html('basic.graphml', Graphml, []),
    open('graph.pl', write, Out),
        print_term(Graphml, [output(Out)]),
        flush_output(Out),    
    close(Out),
    writeln(ya).


% Load the file and extract the graph information.
run :-
    load_html('basic.graphml', [Graphml], []),
    interpret_graphml(Graphml).


% Interpret the parsed structure for the whole graphml file.
interpret_graphml( element(graphml, _Graphml_prop_list, Graphml_element_list) ) :-
    interpret_graphml_element_list(Graphml_element_list).


% Interpret the list of elements within a graphml.
interpret_graphml_element_list(Graphml_element_list) :-
    writeln('--- interpret_graphml_element_list ---'),
    keys(Graphml_element_list, Key_list),
    format('Key_list: ~w~n', [Key_list]),
    memberchk(element(graph, _Graph_prop_list, Graph_element_list), Graphml_element_list),
    interpret_graph_element_list(Graph_element_list, Key_list).


%! interpret_graph_element_list(++Element_list:list, ++Key_list:list).
% Interpret the list of graph elements.
%
% @arg Element_list list of graph elements
% @agr Key_list list of key(From, Attr, Key)
interpret_graph_element_list([], _).

interpret_graph_element_list([H|T], Keys) :-
    writeln('--- interpret_graph_element_list ---'),
    format('H: ~w~n', [H]),
    interpret_graph_element(H, Keys),
    interpret_graph_element_list(T, Keys).


%! interpret_graph_element( ++Element:term, ++Key_list ) is det.
% Extract and print the features of a graph Element.
%
% @arg Element term to be evaluated
% @agr Key_list list of key(From, Attr, Key)
interpret_graph_element( element(node, Node_props, Node_elements), Key_list ) :- !,
    writeln('--- interpret_graph_element ---'),
    format('Key_list: ~w~n', [Key_list]),
    memberchk(id=Node_id, Node_props),
    % memberchk(key(node, description, Key_node_description), Key_list),
    % data(Key_node_description, Node_elements, Node_description),

    member(element(data, _Data_props, Data_elements), Node_elements),
    member(element('y:ImageNode', _Image_props, Image_elements ), Data_elements),
    member(element('y:NodeLabel', _Label_props, Label_elements), Image_elements),
    member(Node_label, Label_elements),
    writeln(node(Node_id, Node_label, Node_description)).

data(Key, Elements, Sub_elements) :-
    member(element(data, Props, Sub_elements), Elements),
    member([key=Key], Props),
    !.

interpret_graph_element( element(edge, Edge_props, Edge_elements), Key_list ) :- !,
    memberchk(id=Edge_id, Edge_props),
    memberchk(source=Source_id, Edge_props),
    memberchk(target=Target_id, Edge_props),
    member(element(data, _Data_props, Data_elements), Edge_elements),
    member(element(_Edge_type, _Edge_type_props, Edge_type_elements), Data_elements),
    member(element('y:EdgeLabel', _Label_props, Label_elements), Edge_type_elements),
    member(Edge_label, Label_elements), atom(Edge_label),
    writeln(edge(Edge_id, Source_id, Target_id, Edge_label)).

interpret_graph_element(_, _).


%! keys(++Elements:list, -Keys:list) :-
% Extract Keys of interest from Elements
%
% @arg Elements list of elements to pull keys from
% @arg Keys list of terms key(For, Attr, Key)
keys(Elements, Keys) :-
    findall(
        key(For, Attr, Key),
        (
            member(
                (For, Attr),
                [
                    (node, nodegraphics)
                    ,(node, description)
                    ,(edge, edgegraphics)
                    ,(edge, description)
                ]
            ),
            key(Elements, For, Attr, Key)
        ),
        Keys
    ).


%! key(++Elements:list, +For:atom, +Attr_name:atom, -Key) is det.
% Extract the Key used for the Attr_name of the For type of element.
%
% @arg Elements list of graphml elements
% @arg For type of element as described in its propertied
% @arg Attr_name name of the attribute of interest
% @arg Key used for the corresponding For type of element and given Attr_name
key(Elements, For, Attr_name, Key) :-
    member(element(key, Key_props, _), Elements),
    member(for=For, Key_props),
    (   member('attr.name'=Attr_name, Key_props)
    ;   member('yfiles.type'=Attr_name, Key_props)
    ),
    member(id=Key, Key_props),
    !.


