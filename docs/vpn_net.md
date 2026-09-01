# Wireguard networks

## External net (10.58.85.0/24)
This network is reachable from the internet and is currently homed on ENA.
Nodes: 
- 10.58.85.1: Ena
- 10.58.85.2: Jenny (Routing 10.58.84.0/24 <-> 10.58.85.0/24)

## Internal net (10.58.86.0/24)
This network is only reachable from inside the concordia network. Currently homed on Jenny, but is unused.
Nodes:
- 10.58.86.1: Jenny

