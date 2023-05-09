/** <module> readit - Read graph information from a yEd graphml file
 * 
 * Extraction of features from a yEd graphml file, using SWI Prolog.
 * 
 * @author Carlos Lang-Sanou
 */

 :- module(read_graphml, [read_graphml/2]).


%! read_graphml(+File_basename:atom, -Term_list:list) is det
% Read the file File_basename.graphml and produce the corresponding list of terms
%
% @arg File_basename base-name filename without its file extension 
% @arg Term_list list of corresponding terms for the graph.
read_graphml(Base_name, Term_list) :-
    atomic_list_concat([Base_name, '.graphml'], Graphfile),
    load_html(Graphfile, [Graphml], []),
    graphml_term_list(Graphml, Term_list).


%! dump_graph(+File_basename:atom) is det
% Read the file File_basename.graphml and write the parsed structure into File_basename.pl
%
% @arg File_basename base-name filename without its file extension 
dump_graph(Base_name) :-
    atomic_list_concat([Base_name, '.graphml'], Graphfile),
    atomic_list_concat([Base_name, '.pl'], PLfile),
    load_html(Graphfile, Graphml, []),
    open(PLfile, write, Out),
        print_term(Graphml, [output(Out)]),
        writeln(Out, '.'),
        flush_output(Out),
    close(Out).


%! run(+File_basename:atom) is det
% Read the file File_basename.graphml and print the corresponding list of terms
%
% @arg File_basename base-name filename without its file extension 
run(Base_name) :-
    read_graphml(Base_name, Term_list),
    print_term(Term_list, []),
    !.


%! new_node(Node_dict) is det.
% defines the structure of a node dict
new_node(node{id:_, label:_, description:_}).

%! new_edge(Edge_dict) is det.
% defines the structure of an edge dict
new_edge(edge{id:_, source_id:_, target_id:_, label:_}).


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
    Node
) :- !,
    memberchk(id=Node_id, Node_props),
    node_description(Node_elements, Node_description, Attr_key_list),
    node_label(Node_elements, Node_label, Attr_key_list),
    new_node(Node),
    Node.id = Node_id, Node.label = Node_label, Node.description = Node_description.


% edge(Edge_id:atom, Source_id:atom, Target_id:atom, Edge_label:string)
graph_element_term(
    element(edge, Edge_props, Edge_elements),
    Attr_key_list,
    Edge
) :- !,
    memberchk(id=Edge_id, Edge_props),
    memberchk(source=Source_id, Edge_props),
    memberchk(target=Target_id, Edge_props),
    edge_label(Edge_elements, Edge_label, Attr_key_list),
    new_edge(Edge),
    Edge.id = Edge_id, Edge.source_id = Source_id, Edge.target_id = Target_id, Edge.label = Edge_label.


%! node_description(++Node_element_list:list, -Node_description:string, ++Attr_key_list) is det
% Node_description is the node description found in Node_element_list
% where Attr_key_list is used to 
% 
% @arg Node_element_list list of elements describing the node
% @arg Node_description description for the node
% @arg Attr_key_list list of attribute keys to be used for reference
node_description(Node_element_list, Node_description, Attr_key_list) :-
    memberchk(key(node, description, Key_node_description), Attr_key_list),
    data(Key_node_description, Node_element_list, [Node_description]), !.

node_description(_, "", _).


%! node_label(++Node_element_list:list, -Node_label:string, ++Attr_key_list:list) is det
% Node_label is the node label found in Node_element_list
% where Attr_key_list is used to 
%
% @arg Node_element_list list of elements describing the node
% @arg Node_label label for the node
% @arg Attr_key_list list of attribute keys to be used for reference
node_label(Node_element_list, Node_label, Attr_key_list) :-
    memberchk(key(node, nodegraphics, Key_nodegraphics), Attr_key_list),
    (
        data(Key_nodegraphics, Node_element_list, Nodegraphics_elements),
        member(element('y:ImageNode', _Image_props, Image_elements ), Nodegraphics_elements),
        member(element('y:NodeLabel', _Label_props, [Node_label]), Image_elements)
    ;
        Node_label = ""
    ),
    !.

%! edge_label(Edge_element_list, Edge_label, Attr_key_list).
% Edge_label is the edge label found in Edge_element_list
% where Attr_key_list is used to 
%
% @arg Edge_element_list list of elements describing the node
% @arg Edge_label label for the node
% @arg Attr_key_list list of attribute keys to be used for reference
edge_label(Edge_element_list, Edge_label, Attr_key_list) :-
    memberchk(key(edge, edgegraphics, Key_edgegraphics), Attr_key_list),
    (
        data(Key_edgegraphics, Edge_element_list, Edgegraphics_elements),
        member(element(_Graphic_type, _Graphic_type_props, Graphic_type_elements), Edgegraphics_elements),
        member(element('y:EdgeLabel', _Label_props, Label_elements), Graphic_type_elements),
        member(Edge_label_1, Label_elements),
        normalize_space(atom(Edge_label),Edge_label_1)
    ;
        Edge_label = ''
    ),
    !.


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
