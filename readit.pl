/** readit - Read graph information from a yEd graphml file
 * 
 * @author Carlos Lang-Sanou
 * 
 */


% Show the parsed structure of the whole file.
show_full :-
    load_html('basic.graphml', Graphml, []),
    print_term(Graphml,[]).


% Load the file and extract the graph information.
run :-
    load_html('basic.graphml', [Graphml], []),
    interpret_graphml(Graphml).


% Interpret the parsed structure for the whole graphml file.
interpret_graphml( element(graphml, _graphml_prop_list, Graphml_element_list) ) :-
    interpret_graphml_element_list(Graphml_element_list).


% Interpret the list of elements within a graphml.
interpret_graphml_element_list(Graphml_element_list) :-
    memberchk(element(graph, _graph_prop_list, Graph_element_list), Graphml_element_list),
    interpret_graph_element_list(Graph_element_list).


% Interpret the list of elements within a graph.
interpret_graph_element_list([]).

interpret_graph_element_list([H|T]) :-
    interpret_graph_element(H),
    interpret_graph_element_list(T).


% Interpret graph element: node
interpret_graph_element( element(node, Node_props, Node_elements) ) :- !,
    memberchk(id=Node_id, Node_props),
    member(element(data, Data_props, Data_elements), Node_elements),
    member(element('y:ImageNode', _image_props, Image_elements ), Data_elements),
    member(element('y:NodeLabel', _label_props, Label_elements), Image_elements),
    member(Node_label, Label_elements),
    writeln(node(Node_id, Node_label)).


% Interpret graph element: edge
interpret_graph_element( element(edge, Edge_props, Edge_elements) ) :- !,
    memberchk(id=Edge_id, Edge_props),
    memberchk(source=Source_id, Edge_props),
    memberchk(target=Target_id, Edge_props),
    member(element(data, Data_props, Data_elements), Edge_elements),
    member(element(_edge_type, _edge_type_props, Edge_type_elements), Data_elements),
    member(element('y:EdgeLabel', _label_props, Label_elements), Edge_type_elements),
    member(Edge_label, Label_elements), atom(Edge_label),
    writeln(edge(Edge_id, Source_id, Target_id, Edge_label)).


% Interpret graph element: any other.
interpret_graph_element(_).
