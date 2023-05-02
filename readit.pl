/** readit - Read graph information from a yEd graphml file
 * 
 * Extraction of features from a yEd graphml file, using SWI Prolog.
 * 
 * @author Carlos Lang-Sanou
 * 
 */


% Show the parsed structure of the whole file.
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
    memberchk(element(graph, _Graph_prop_list, Graph_element_list), Graphml_element_list),
    interpret_graph_element_list(Graph_element_list).


%! interpret_graph_element_list(++List:list).
% Interpret the list of graph elements.
%
% @arg List list of graph elements
interpret_graph_element_list([]).

interpret_graph_element_list([H|T]) :-
    interpret_graph_element(H),
    interpret_graph_element_list(T).


%! interpret_graph_element( ++Element:term ) is det.
% Extract and print the features of a graph Element.
%
% @arg Element term to be evaluated
interpret_graph_element( element(node, Node_props, Node_elements) ) :- !,
    memberchk(id=Node_id, Node_props),
    member(element(data, _Data_props, Data_elements), Node_elements),
    member(element('y:ImageNode', _Image_props, Image_elements ), Data_elements),
    member(element('y:NodeLabel', _Label_props, Label_elements), Image_elements),
    member(Node_label, Label_elements),
    writeln(node(Node_id, Node_label)).

interpret_graph_element( element(edge, Edge_props, Edge_elements) ) :- !,
    memberchk(id=Edge_id, Edge_props),
    memberchk(source=Source_id, Edge_props),
    memberchk(target=Target_id, Edge_props),
    member(element(data, _Data_props, Data_elements), Edge_elements),
    member(element(_Edge_type, _Edge_type_props, Edge_type_elements), Data_elements),
    member(element('y:EdgeLabel', _Label_props, Label_elements), Edge_type_elements),
    member(Edge_label, Label_elements), atom(Edge_label),
    writeln(edge(Edge_id, Source_id, Target_id, Edge_label)).

interpret_graph_element(_).


%! key(++Elements:list, +Key_name:atom, -Key) is det.
% Extract the Key associated with a Key_Name
%
% @arg Elements list of graphml elements
% @arg Key_name one of node_description, node_graphics, ...
key(Elements, node_description, Key) :-
    memberchk(element(key, Key_props, _), Elements),
    memberchk(for=node, Key_props),
    memberchk('attr.name'=description, Key_props),
    memberchk(id=Key, Key_props).

key(Elements, node_graphics, Key) :-
    memberchk(element(key, Key_props, _), Elements),
    memberchk(for=node, Key_props),
    memberchk('yfiles.type'=nodegraphics, Key_props),
    memberchk(id=Key, Key_props).

