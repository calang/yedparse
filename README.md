# yedparse
Extraction of features from a yEd graphml file, using SWI Prolog.

## Motivation
We are looking for
- an easy, agile way to produce graphs, as in "nodes connected through edges" with some GUI, and later
- be able to extract and process the information stored in the graph

Information to be processed includes
- node information: their labels and any other property
- edge information: which nodes are connected to other and what properties those connections have.

## Requirements
- [yEd](https://www.yworks.com/products/yed)
- [SWI-Prolog](https://www.swi-prolog.org/)

## Tool selection
For the GUI, we chose [yEd](https://www.yworks.com/products/yed)

- feely available
- available in multiple platforms
- stores its graphs in very concise XML.

For the extraction and interpretation, [SWI-Prolog](https://www.swi-prolog.org/)

- freely available in multiple platforms and open source (Simplified BSD license)
- comprehensive set of libraries
- very easy reading and interpretation of XML files
- very easy and effective manipulation of relationships
- widely used in research, education and commercial applications

## Assumptions
- The graph has a single level, with no layers or compound (grouped) nodes

## Examples
### basic.graphml, read by readit.pl

## To do
- alter the current predicates so that instead of "printing" the graph structure they returns a parsed graph term
- pull graph features by key element types (e.g. d5, d6), for more precise extractions
- capture the type of node, from the node data Description
- enable the predicates to read and compile additional interesting properties of nodes and edges
- transform the readit.pl script into a module with a predicate that imports graph features from a given graph file

