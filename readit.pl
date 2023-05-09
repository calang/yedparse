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
    graphml_term_list(Graphml, Term_list),
    print_term(Term_list, []),
    !.


%! graphml_term_list(++Graph_element:term, -Term_list:list) is det
% Term_list is the list of terms for Graph_element
%
% @arg Graph_element term of the form element(graphml, _Graphml_prop_list, Element_list)
% @arg Term_list list of corresponding list of terms for the given graph.
graphml_term_list( element(graphml, _Graphml_prop_list, Element_list), Term_list ) :-
    keys(Element_list, Key_list),
    memberchk(element(graph, _Graph_prop_list, Graph_element_list), Element_list),
    element_list_term_list(Graph_element_list, Key_list, Term_list).


%! element_list_term_list(++Element_list:list, ++Attr_key_list:list, -Term_list:list) is det
% Term_list is the list of terms that corresponds to Element_list
% given the list of attribute keys Attr_key_list
%
% @arg Element_list list of graph elements
% @arg Attr_key_list list of key(From, Attr, Key)
% @arg Term_list list of terms extracted from the Element_list
element_list_term_list(Element_list, Attr_key_list, Term_list) :-
    findall(
        Term,
        (
            member(Element, Element_list),
            graph_element_term(Element, Attr_key_list, Term)
        ),
        Term_list
    ).


%! graph_element_term( ++Element:term, ++Attr_key_list:list, -Term ) is det
% Term is the term that corresponds to Element.
%
% @arg Element graph element
% @arg Attr_key_list list of element attribute keys of the form key(From, Attr, Key)
% @arg Term term corresponding to Element

% node(Node_id:atom, Node_label:string, Node_description:string)
graph_element_term(
    element(node, Node_props, Node_elements),
    Attr_key_list,
    node(Node_id, Node_label, Node_description)
) :- !,
    memberchk(id=Node_id, Node_props),
    memberchk(key(node, description, Key_node_description), Attr_key_list),
    data(Key_node_description, Node_elements, [Node_description]),

    memberchk(key(node, nodegraphics, Key_nodegraphics), Attr_key_list),
    data(Key_nodegraphics, Node_elements, Nodegraphics_elements),

    member(element('y:ImageNode', _Image_props, Image_elements ), Nodegraphics_elements),
    member(element('y:NodeLabel', _Label_props, [Node_label]), Image_elements).

% edge(Edge_id:atom, Source_id:atom, Target_id:atom, Edge_label:string)
graph_element_term(
    element(edge, Edge_props, Edge_elements),
    Attr_key_list,
    edge(Edge_id, Source_id, Target_id, Edge_label)
) :- !,
    memberchk(id=Edge_id, Edge_props),
    memberchk(source=Source_id, Edge_props),
    memberchk(target=Target_id, Edge_props),

    memberchk(key(edge, edgegraphics, Key_edgegraphics), Attr_key_list),
    data(Key_edgegraphics, Edge_elements, Edgegraphics_elements),

    member(element(_Graphic_type, _Graphic_type_props, Graphic_type_elements), Edgegraphics_elements),
    member(element('y:EdgeLabel', _Label_props, Label_elements), Graphic_type_elements),
    member(Edge_label, Label_elements), atomic(Edge_label).


%! data(+Key_id:atom, ++Element_list:list, -Sub_element_list:list) is nondet
% Sub_element_list is the list of sub_elements
% of an element within Element_list
% of type 'data' and key=Key_id
%
% @arg Key_id of the data searched for
% @arg Element_list list of elements among which to search for a data element
% @arg Sub_element_list content of the data element in Element_list with the given Key_id
data(Key_id, Element_list, Sub_element_list) :-
    member(element(data, Props, Sub_element_list), Element_list),
    member(key=Key_id, Props).


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


%! key(++Element_list:list, +Element_type:atom, +Attr_name:atom, -Key_id:atom) is det
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
