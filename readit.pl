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
        writeln(Out, '.'),
        flush_output(Out),
    close(Out).


%! run is det
% Load the file and print the graph information.
run :-
    load_html('basic.graphml', [Graphml], []),
    interpret_graphml(Graphml),
    !.


%! interpret_graphml(++Element:term) is det
% Interpret the parsed Element structure for the whole graphml file.
%
% @arg Element term of the form element(graphml, _Graphml_prop_list, Graphml_element_list)
interpret_graphml( element(graphml, _Graphml_prop_list, Graphml_element_list) ) :-
    interpret_graphml_element_list(Graphml_element_list, Term_list),
    print_term(Term_list, []).


%! interpret_graphml_element_list(++Graphml_element_list:list,-Term_list:list) is det
% Interpret the list of elements within a graphml.
%
% @arg Graphml_element_list - list of graphml elements
% @arg Term_list list of terms extracted from the graphml
interpret_graphml_element_list(Graphml_element_list, Term_list) :-
    keys(Graphml_element_list, Key_list),
    memberchk(element(graph, _Graph_prop_list, Graph_element_list), Graphml_element_list),
    interpret_graph_element_list(Graph_element_list, Key_list, Term_list).


%! interpret_graph_element_list(++Element_list:list, ++Key_list:list, -Term_list:list) is det
% Interpret the list of graph elements.
%
% @arg Element_list list of graph elements
% @arg Key_list list of key(From, Attr, Key)
% @arg Term_list list of terms extracted from the Element_list
interpret_graph_element_list(Element_list, Keys, Term_list) :-
    findall(
        Term,
        (
            member(Element, Element_list),
            interpret_graph_element(Element, Keys, Term)
        ),
        Term_list
    ).


%! interpret_graph_element( ++Element:term, ++Key_list:list, -Term ) is det.
% Extract and print the features of a graph Element.
%
% @arg Element term to be evaluated
% @arg Key_list list of key(From, Attr, Key)
% @arg Term term produced from interpreting the Element
interpret_graph_element(
    element(node, Node_props, Node_elements),
    Key_list,
    node(Node_id, Node_label, Node_description)
) :- !,
    memberchk(id=Node_id, Node_props),

    memberchk(key(node, description, Key_node_description), Key_list),
    data(Key_node_description, Node_elements, [Node_description]),

    memberchk(key(node, nodegraphics, Key_nodegraphics), Key_list),
    data(Key_nodegraphics, Node_elements, Nodegraphics_elements),

    member(element('y:ImageNode', _Image_props, Image_elements ), Nodegraphics_elements),
    member(element('y:NodeLabel', _Label_props, [Node_label]), Image_elements).

interpret_graph_element(
    element(edge, Edge_props, Edge_elements),
    Key_list,
    edge(Edge_id, Source_id, Target_id, Edge_label)
) :- !,
    memberchk(id=Edge_id, Edge_props),
    memberchk(source=Source_id, Edge_props),
    memberchk(target=Target_id, Edge_props),

    % memberchk(key(edge, description, Key_edge_description), Key_list),
    % data(Key_edge_description, Node_elements, [Node_description]),

    memberchk(key(edge, edgegraphics, Key_edgeraphics), Key_list),
    data(Key_edgeraphics, Edge_elements, Edgegraphics_elements),

    member(element(_Edge_type, _Edge_type_props, Edge_type_elements), Edgegraphics_elements),
    member(element('y:EdgeLabel', _Label_props, Label_elements), Edge_type_elements),
    member(Edge_label, Label_elements), atomic(Edge_label).


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


%! element_attribute(?Element_type, ?Attr_name) is nondet
% Attr_name is the name of an attribute of interest for elements of type Element_type
%
% @arg Element_type type of element
% @arg Attr_name name of the attribute 
element_attribute(node, nodegraphics).
element_attribute(node, description).
element_attribute(edge, edgegraphics).
element_attribute(edge, description).


%! keys(++Element_list:list, -Key_list:list) is det
% Key_list is the list of terms of form key(element_type, attribute_name, key_id),
% corresponding to elements in Element_list which define key_ids
%
% @arg Element_list list of elements to pull keys from
% @arg Key_list list of terms of the form key(element_type, attribute_name, key_id)
keys(Elements, Keys) :-
    findall(
        key(For, Attr, Key_id),
        (
            element_attribute(For, Attr),
            key(Elements, For, Attr, Key_id)
        ),
        Keys
    ).


%! key(++Element_list:list, +Element_type:atom, +Attr_name:atom, -Key_id:atom) is det.
% Key_id is used for the Attr_name of the Element_type.
%
% @arg Element_list list of graphml elements
% @arg Element_type type of element
% @arg Attr_name name of the attribute
% @arg Key_id used for the corresponding Element_type and Attr_name
key(Element_list, Element_type, Attr_name, Key_id) :-
    member(element(key, Key_props, _), Element_list),
    member(for=Element_type, Key_props),
    (   member('attr.name'=Attr_name, Key_props)
    ;   member('yfiles.type'=Attr_name, Key_props)
    ),
    member(id=Key_id, Key_props),
    !.
