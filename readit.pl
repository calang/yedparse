/** <module> readit - Read graph information from a yEd graphml file
 * 
 * Extraction of features from a yEd graphml file, using SWI Prolog.
 * 
 * @author Carlos Lang-Sanou
 */


%! dump_graph is det
% Write the parsed structure of the whole graphml file onto a file called 'graph.pl'
dump_graph :-
    load_html('basic.graphml', Graphml, []),
    open('graph.pl', write, Out),
        print_term(Graphml, [output(Out)]),
        flush_output(Out),    
    close(Out),
    writeln(ya).


%! run is det
% Load the file and print the graph information.
run :-
    load_html('basic.graphml', [Graphml], []),
    interpret_graphml(Graphml).


%! interpret_graphml(++Element:term) is det
% Interpret the parsed Element structure for the whole graphml file.
%
% @arg Element term of the form element(graphml, _Graphml_prop_list, Graphml_element_list)
interpret_graphml( element(graphml, _Graphml_prop_list, Graphml_element_list) ) :-
    interpret_graphml_element_list(Graphml_element_list).


%! interpret_graphml_element_list(++Graphml_element_list:list) is det
% Interpret the list of elements within a graphml.
%
% @arg Graphml_element_list - list of graphml elements
interpret_graphml_element_list(Graphml_element_list) :-
    % writeln('--- interpret_graphml_element_list ---'),
    keys(Graphml_element_list, Key_list),
    % format('Key_list: ~w~n', [Key_list]),
    memberchk(element(graph, _Graph_prop_list, Graph_element_list), Graphml_element_list),
    interpret_graph_element_list(Graph_element_list, Key_list).


%! interpret_graph_element_list(++Element_list:list, ++Key_list:list) is det
% Interpret the list of graph elements.
%
% @arg Element_list list of graph elements
% @arg Key_list list of key(From, Attr, Key)
interpret_graph_element_list([], _).

interpret_graph_element_list([H|T], Keys) :-
    % writeln('--- interpret_graph_element_list ---'),
    % format('H: ~w~n', [H]),
    interpret_graph_element(H, Keys),
    interpret_graph_element_list(T, Keys).


%! interpret_graph_element( ++Element:term, ++Key_list:list ) is det.
% Extract and print the features of a graph Element.
%
% @arg Element term to be evaluated
% @arg Key_list list of key(From, Attr, Key)
interpret_graph_element( element(node, Node_props, Node_elements), Key_list ) :- !,
    memberchk(id=Node_id, Node_props),

    memberchk(key(node, description, Key_node_description), Key_list),
    data(Key_node_description, Node_elements, [Node_description]),

    memberchk(key(node, nodegraphics, Key_nodegraphics), Key_list),
    data(Key_nodegraphics, Node_elements, Nodegraphics_elements),

    member(element('y:ImageNode', _Image_props, Image_elements ), Nodegraphics_elements),
    member(element('y:NodeLabel', _Label_props, [Node_label]), Image_elements),
    writeln(node(Node_id, Node_label, Node_description)).

interpret_graph_element( element(edge, Edge_props, Edge_elements), Key_list ) :- !,
    memberchk(id=Edge_id, Edge_props),
    memberchk(source=Source_id, Edge_props),
    memberchk(target=Target_id, Edge_props),

    % memberchk(key(edge, description, Key_edge_description), Key_list),
    % data(Key_edge_description, Node_elements, [Node_description]),

    memberchk(key(edge, edgegraphics, Key_edgeraphics), Key_list),
    data(Key_edgeraphics, Edge_elements, Edgegraphics_elements),

    member(element(_Edge_type, _Edge_type_props, Edge_type_elements), Edgegraphics_elements),
    member(element('y:EdgeLabel', _Label_props, Label_elements), Edge_type_elements),
    member(Edge_label, Label_elements), atomic(Edge_label),
    writeln(edge(Edge_id, Source_id, Target_id, Edge_label)).

interpret_graph_element(_,_).


%! data(+Key:atom, ++Elements, -Sub_elements) is det
% Extract the Sub_elements content from a data element in Elements with a given Key
%
% @arg Key used to select the desired data element
% @arg Elements list of elements to search data from
% @arg Sub_elements content of the data element in Elements with the given Key
data(Key, Elements, Sub_elements) :-
    member(element(data, Props, Sub_elements), Elements),
    member(key=Key, Props),
    !.


%! keys(++Elements:list, -Keys:list) is det
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


