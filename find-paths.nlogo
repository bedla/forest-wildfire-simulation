extensions 
[ 
  palette
] 

breed [ finders finder ]
breed [ nodes node ]

globals
[
  min-height
  max-height
  
  low-lands
  high-lands
  
  deleni-x
  deleni-y  
  max-parcel-x
  max-parcel-y
  
  main-finder
  
  base
  
  infinity
  
  clicked?
  
  low-land-parcels
  high-land-parcels

  created-links  
]

patches-own
[
  height
  
  parcel-x
  parcel-y
  
  left-neighbors
  right-neighbors
  up-neighbors
  down-neighbors

  left-top-neighbors
  left-bottom-neighbors
  right-top-neighbors
  right-bottom-neighbors
  
  visited?
  
  is-low-land?
  is-high-land?
]

finders-own
[
  visited-list
]

nodes-own
[
  dist
  previous
  node-parcel-x
  node-parcel-y
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  reset-timer

  clear-all
  
  set infinity 999999999
  
  set clicked? false
  
  load-patch-data
  
  set min-height min [ height ] of patches
  set max-height max [ height ] of patches

  set created-links []

  set low-land-parcels []
  set high-land-parcels []


  let prechod [[170 170 255] [128 128 0] [0 128 0] [192 192 192] [255 255 255]]
  ask patches 
  [
    set pcolor palette:scale-gradient prechod height min-height max-height
    set is-low-land? false
    set is-high-land? false
  ]
  
  print (word "setup in " timer " s")  
  
  find-paths-setup
end

to load-patch-data

  if ( file-exists? "teren.txt" )
  [
    file-open "teren.txt"
  
    let row 0
    while [ not file-at-end? ]
    [
      let seznam read-from-string (word "[" file-read-line "]")
      let seznam-length length seznam
      ifelse seznam-length = world-width and seznam-length = world-height
      [
        let col 0
        foreach seznam 
        [            
          ask patch row col
          [
            set height ?
          ]
        set col col + 1
      ]   
    ]
    [
      print seznam
    ]
    set row row + 1
  ]
    file-close
  ]  
  
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to find-paths-setup

  ask finders
  [
    die
  ]

  ask patches
  [
    set visited? false
  ]

  set low-lands get-low-lands 0.1
  set high-lands get-high-lands 0.2

  ask low-lands
  [
    set is-low-land? true
  ]
    
  ask high-lands
  [
    set is-high-land? true
  ]

  ask one-of low-lands
  [
    sprout-finders 1
    [
      set size 5
      set color red
      let thisNode nobody
      hatch-nodes 1
      [
        set shape "circle"
        set size 5
        set color blue
        set thisNode self
        set node-parcel-x parcel-x
        set node-parcel-y parcel-y
      ]
      set visited-list lput thisNode []
      
      set base thisNode
       
      set main-finder self
    ]
  ]
  
  create-parcels
    
  ;setup-parcel-neighbors4
  setup-parcel-neighbors
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to create-paths

  if empty? [ visited-list ] of main-finder
  [
    stop
  ]

  ask main-finder
  [
    if not empty? visited-list
    [
      let currentNode first visited-list
      set visited-list but-first visited-list
    
      set xcor [ xcor ] of currentNode
      set ycor [ ycor ] of currentNode
      
      let sousedi []
      ; vytvorim seznam vsech patchu ve 4 sousedi
      ;foreach ( list left-neighbors right-neighbors up-neighbors down-neighbors )
      foreach ( list left-neighbors right-neighbors up-neighbors down-neighbors left-top-neighbors left-bottom-neighbors right-top-neighbors right-bottom-neighbors )
      [
        ; ale zaradim jen ty co nebyly navstiveni
        if any? ? and not [ visited? ] of one-of ?
        [
          set sousedi lput ? sousedi
        ]
      ]
    
      set sousedi filter [ any? ? ] sousedi
      ; zjistim parcelu, ktera je z nich nejmensi
      let parcely min-parcels sousedi 0.3
      
      ; projdu vsechy vyhovojujici parcely
      foreach parcely
      [
        ; presunu se na jeden patch z aktualni parcely
        move-to one-of ?

        let thisNode nobody
        hatch-nodes 1
        [
          set shape "circle"
          set size 5
          set color blue
          set thisNode self
          set node-parcel-x parcel-x
          set node-parcel-y parcel-y
        ]
  
        ask currentNode
        [
          ; obarvnime spojeni nacerveno
          create-link-with thisNode
          [
            set color red
          ]
        ]
        
        set visited-list lput thisNode visited-list
        ask ?
        [
          set visited? true
        ]
        
      ]
      
    ]
  ]
end

;to find-paths-go-do-hloubky
;
;  if all? patches [ visited? ]
;  [
;    stop
;  ]
;
;  ask main-finder
;  [
;    let sousedi []
;    ; vytvorim seznam vsech patchu ve 4 sousedi
;    foreach ( list left-neighbors right-neighbors up-neighbors down-neighbors )
;    [
;      ; ale zaradim jen ty co nebyly navstiveni
;      if any? ? and not [ visited? ] of one-of ?
;      [
;        set sousedi lput ? sousedi
;      ]
;    ]
;    
;    set sousedi filter [ any? ? ] sousedi
;    ; zjistim parcelu, ktera je z nich nejmensi
;    let parcela min-parcel sousedi
;    
;    ; pokud existuje nenavstivena parcela
;    ifelse any? parcela
;    [
;      ; presun se na jeden nahodny patch z nenavstivene parcely
;      move-to one-of parcela
;      
;      ; vytvorime vrchol
;      let thisNode nobody
;      hatch-nodes 1
;      [
;        set shape "circle"
;        set size 5
;        set color blue1
;        set thisNode self
;      ]
;      
;      ; spojime vrchol s poslednim prvkem v seznamu nalezenych vrcholu
;      ask last visited-list
;      [
;        ; obarvnime spojeni na cerveno
;        create-link-with thisNode
;        [
;          set color red
;        ]
;      ]
;      
;      ; ulozime vytvoreny vrchol na konec navstiveneho seznamu
;      set visited-list lput thisNode visited-list
;      ask parcela
;      [
;        set visited? true
;      ]
;    ]
;    [ ; pokud uz zadnou nenavstivenou parcelu nevidim
;      ; a seznam navstivenych vrcholu neni prazdny
;      if not empty? visited-list
;      [ 
;        ; nacteme posledni navstiveny vrchol
;        let posledni last visited-list
;        ; zmenime pozici hledace
;        set xcor [xcor] of posledni
;        set ycor [ycor] of posledni
;        ; a odebereme posledni navstiveny vrchol ze seznamu navstivenych vrcholu
;        set visited-list but-last visited-list
;      ]
;    ]
;  ]
;end

to-report min-parcel [ list-parcels ]
  if empty? list-parcels
  [
    report no-patches
  ]
  
  let min-neighbors item 0 list-parcels  
  let min-value min [ height ] of min-neighbors
  
  foreach list-parcels
  [
    if min [ height ] of ? < min-value
    [
      set min-neighbors ?
      set min-value min [ height ] of ?
    ]
  ]
  
  report min-neighbors
end

to-report min-parcels [ list-parcels max-height-percent ]
  let result []
  
  if empty? list-parcels
  [    
    report result
  ]
  
  ; zjistim si maximalni lokalni hodnotu v okoli
  let max-neighbors item 0 list-parcels  
  let max-value max [ height ] of max-neighbors  
  foreach list-parcels
  [
    if max [ height ] of ? > max-value
    [
      set max-neighbors ?
      set max-value max [ height ] of ?
    ]
  ]

  ; vypoctu si po jakou hodnotu bude okoli povazovano za kopec
  let max-height-value max-value * max-height-percent

  foreach list-parcels
  [
    if min [ height ] of ? < max-height-value
    [
      set result lput ? result
    ]
  ]
  
  report result
end


to mouse-down
  if mouse-down?
  [
    ask patch mouse-xcor mouse-ycor
    [
      let a parcel-neighbors self
    ]
  ]
end

to mouse-down-get-shortest-path
  if mouse-down?
  [
    ask patch mouse-xcor mouse-ycor
    [
      if any? nodes-here and not clicked?
      [
        set clicked? true
      
        ask links
        [
          set thickness 0
        ]

        let path get-shortest-path one-of nodes-here
        
        print path
        
        while [ not empty? path ]
        [
          let a first path
          set path but-first path
          
          if not empty? path 
          [
            let b first path
          
            ask link ([who] of a) ([who] of b)
            [
              set thickness 3
            ]
          ]
        ]
        set clicked? false
      ]
    ]
  ]
end

; pro vsechny parcely najde jejich sousedy
; nastavuje sousedy pro kazdy patch
to setup-parcel-neighbors4
  reset-timer 

  let x min-pxcor + deleni-x * 0.5
  while [ x <= max-pxcor ]
  [
    let y min-pycor + deleni-y * 0.5
    while [ y <= max-pycor ]
    [
      let sousedi parcel-neighbors4 patch x y
      let this-parcel-x [ parcel-x ] of patch x y
      let this-parcel-y [ parcel-y ] of patch x y
      
      ask patches with [ parcel-x = this-parcel-x and parcel-y = this-parcel-y ]
      [
        set left-neighbors item 0 sousedi
        set right-neighbors item 1 sousedi
        set up-neighbors item 2 sousedi
        set down-neighbors item 3 sousedi
      ]
      set y y + deleni-y
    ]
    set x x + deleni-x
  ]
  
  print (word "setup-parcel-neighbors4 in " timer " s")
end

; vrati sousedni patche parcel pro 4 okoli
; vzdy vrati (list vlevo vpravo nahore dole) - kazdy prvek muze byt empty-agent-set
to-report parcel-neighbors4 [ this-patch ]
  let this-parcel-x [ parcel-x ] of this-patch ; parcela pro X na volanem patchi
  let this-parcel-y [ parcel-y ] of this-patch ; parcela pro Y na volanem patchi

  let that-parcel-x [ parcel-x ] of this-patch ; pomocna parcela X
  let that-parcel-y [ parcel-y ] of this-patch ; pomocna parcela Y

  let x [ pxcor ] of this-patch
  let y [ pycor ] of this-patch
  let break false
  
  let vpravo no-patches 
  let vlevo no-patches 
  let nahore no-patches 
  let dole no-patches 

  ; nalezneme parcelu vpravo ... tj. pricitam X
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ x <= max-pxcor and not break ]
  [
    set that-parcel-x [ parcel-x ] of patch x y
    ; jedu po patches dokud neni cislo parcely v X souradnici rozdilne
    if that-parcel-x != this-parcel-x
    [    
      set break true
    ]
    set x x + 1
  ]  
  if this-parcel-x != that-parcel-x 
  [
    set vpravo patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]

  ; nalezneme parcelu vlevo ... tj. odecitam X
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ x >= min-pxcor and not break ]
  [
    set that-parcel-x [ parcel-x ] of patch x y
    ; jedu po patches dokud neni cislo parcely v X souradnici rozdilne
    if that-parcel-x != this-parcel-x
    [    
      set break true
    ]
    set x x - 1
  ]
  if this-parcel-x != that-parcel-x 
  [
    set vlevo patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]

  ; nalezneme parcelu nahore ... tj. pricitam Y
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ y <= max-pycor and not break ]
  [
    set that-parcel-y [ parcel-y ] of patch x y
    ; jedu po patches dokud neni cislo parcely v Y souradnici rozdilne
    if that-parcel-y != this-parcel-y
    [    
      set break true
    ]
    set y y + 1
  ]  
  if this-parcel-y != that-parcel-y
  [
    set nahore patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]

  ; nalezneme parcelu nahore ... tj. odecitam Y
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ y >= min-pycor and not break ]
  [
    set that-parcel-y [ parcel-y ] of patch x y
    ; jedu po patches dokud neni cislo parcely v Y souradnici rozdilne
    if that-parcel-y != this-parcel-y
    [    
      set break true
    ]
    set y y - 1
  ]  
  if this-parcel-y != that-parcel-y
  [
    set dole patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]
  
  report (list vlevo vpravo nahore dole)
end

; vytvoreni parcel
; parcela je sachovnice ocislovana od nula do max
to create-parcels
  reset-timer
  ; zjistime jak velke deleni mame udelat
  set deleni-x round world-width * 0.1
  set deleni-y round world-height * 0.1
  
  ; a pak prochazime sachovnici podle tohoto deleni
  let i 0
  let x-last min-pxcor
  let x min-pxcor + deleni-x
  while [ x-last <= max-pxcor ]
  [
    let y-last min-pycor
    let y min-pycor + deleni-y
    let j 0
    while [ y-last <= max-pycor ]
    [
      ask patches with 
        [ pxcor >= x-last and pxcor <= x and
          pycor >= y-last and pycor <= y ]
      [
        set parcel-x i
        set parcel-y j
      ]
      
      if any? low-lands with 
        [ pxcor >= x-last and pxcor <= x and
          pycor >= y-last and pycor <= y ]
      [
        set low-land-parcels lput (list i j) low-land-parcels
      ]
      
      if any? high-lands with 
        [ pxcor >= x-last and pxcor <= x and
          pycor >= y-last and pycor <= y ]
      [
        set high-land-parcels lput (list i j) high-land-parcels
      ]      
      
      if show-parcels?
      [
        ask patches with [ pxcor = round x and pcolor != gray ]
        [
          set pcolor gray
        ]
        
        ask patches with [ pycor = round y and pcolor != gray ]
        [
          set pcolor gray
        ]
      ]
      
      set j j + 1
      set y-last y
      set y y + deleni-y
      set max-parcel-y j
    ]
    set i i + 1
    set x-last x
    set x x + deleni-x
    set max-parcel-x i
  ]
  
 set max-parcel-x max-parcel-x - 1
 set max-parcel-y max-parcel-y - 1
 
 print (word "create-parcels in " timer " s")
end

; vrati patche, ktere jsou nizinami
to-report get-low-lands [ boundary ]
  ; nizina je o velikosti min az 20% do celkove likosti
  let avg-min-height min-height + ( max-height - min-height ) * boundary
  report patches with [ height >= min-height and height <= avg-min-height ]
end

; vrati patche, ktere jsou horami
to-report get-high-lands [ boundary ]
  ; hora je o velikosti max - 20% az do max
  let avg-max-height max-height - ( max-height - min-height ) * boundary
  report patches with [ height >= avg-max-height and height <= max-height ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to dijkstra-go
  reset-timer
  
  dijkstra base
  
  ask base
  [
    set color yellow
    set size 10
  ]
   
  print (word "dijkstra-go " timer " s" )
  
  stop
end

to dijkstra [ start-node ]

  ask nodes
  [
    set dist infinity
    set previous nobody
  ]
  
  ask start-node
  [
    set dist 0
  ]
  
  let Q []
  ask nodes
  [
    set Q lput self Q
  ]
  
  while [ not empty? Q ]
  [
    let u min-dist-node Q
    
    if [ dist ] of u != infinity
    [
      set Q remove u Q
                  
      ask [ link-neighbors ] of u
      [
        let uv-distance link-distance u self
        let alt ( [ dist ] of u ) + uv-distance
        if alt < dist
        [
          set dist alt
          let thisV self
          ask thisV
          [
            set previous u
          ]
          
        ]
      ]      
    ]   
  ]
  
  
;  report nobody ;previous
  
;  function Dijkstra(Graph, source):
;      for each vertex v in Graph:           // Initializations
;          dist[v] := infinity               // Unknown distance function from source to v
;          previous[v] := undefined          // Previous node in optimal path from source
;      dist[source] := 0                     // Distance from source to source
;      Q := the set of all nodes in Graph
;        // All nodes in the graph are unoptimized - thus are in Q
;      while Q is not empty:                 // The main loop
;          u := vertex in Q with smallest dist[]
;          if dist[u] = infinity:
;              break                         // all remaining vertices are inaccessible
;          remove u from Q
;          for each neighbor v of u:         // where v has not yet been removed from Q.
;              alt := dist[u] + dist_between(u, v) 
;              if alt < dist[v]:             // Relax (u,v,a)
;                  dist[v] := alt
;                  previous[v] := u
;      return previous[]
  

end

to-report min-dist-node [ Q ]
  if empty? Q
  [
    report nobody
  ]
  
  let result first Q
  let m [ dist ] of result
  foreach Q
  [
    if [ dist ] of ? < m
    [
      set result ?
      set m [ dist ] of ?
    ]
  ]
  report result
end

to-report link-distance [u v]
  let result 0
  ask link [ who ] of u [ who ] of v
  [
    set result link-length
  ]
  report result
end

to-report get-shortest-path [ from-node ]
  let result []
  
  let thisNode from-node
  while [ thisNode != nobody ]
  [
    set result lput thisNode result    
    set thisNode [previous] of thisNode
  ]
  
  report result
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; vrati sousedni patche parcel pro 8mi okoli
; vzdy vrati (list vlevo vpravo nahore dole) - kazdy prvek muze byt empty-agent-set
to-report parcel-neighbors [ this-patch ]
  let this-parcel-x [ parcel-x ] of this-patch ; parcela pro X na volanem patchi
  let this-parcel-y [ parcel-y ] of this-patch ; parcela pro Y na volanem patchi

  let that-parcel-x [ parcel-x ] of this-patch ; pomocna parcela X
  let that-parcel-y [ parcel-y ] of this-patch ; pomocna parcela Y

  let x [ pxcor ] of this-patch
  let y [ pycor ] of this-patch
  let break false
  
  let vpravo no-patches 
  let vlevo no-patches 
  let nahore no-patches 
  let dole no-patches
  let vpravo-nahore no-patches
  let vlevo-nahore no-patches
  let vpravo-dole no-patches
  let vlevo-dole no-patches

  ; nalezneme parcelu vpravo ... tj. pricitam X
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ x <= max-pxcor and not break ]
  [
    set that-parcel-x [ parcel-x ] of patch x y
    ; jedu po patches dokud neni cislo parcely v X souradnici rozdilne
    if that-parcel-x != this-parcel-x
    [    
      set break true
    ]
    set x x + 1
  ]  
  if this-parcel-x != that-parcel-x 
  [
    set vpravo patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]

  ; nalezneme parcelu vlevo ... tj. odecitam X
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ x >= min-pxcor and not break ]
  [
    set that-parcel-x [ parcel-x ] of patch x y
    ; jedu po patches dokud neni cislo parcely v X souradnici rozdilne
    if that-parcel-x != this-parcel-x
    [    
      set break true
    ]
    set x x - 1
  ]
  if this-parcel-x != that-parcel-x 
  [
    set vlevo patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]

  ; nalezneme parcelu nahore ... tj. pricitam Y
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ y <= max-pycor and not break ]
  [
    set that-parcel-y [ parcel-y ] of patch x y
    ; jedu po patches dokud neni cislo parcely v Y souradnici rozdilne
    if that-parcel-y != this-parcel-y
    [    
      set break true
    ]
    set y y + 1
  ]  
  if this-parcel-y != that-parcel-y
  [
    set nahore patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]

  ; nalezneme parcelu nahore ... tj. odecitam Y
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ y >= min-pycor and not break ]
  [
    set that-parcel-y [ parcel-y ] of patch x y
    ; jedu po patches dokud neni cislo parcely v Y souradnici rozdilne
    if that-parcel-y != this-parcel-y
    [    
      set break true
    ]
    set y y - 1
  ]  
  if this-parcel-y != that-parcel-y
  [
    set dole patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ; nalezneme parcelu vpravo nahore ... tj. pricitam X a pricitanim Y
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ x <= max-pxcor and y <= max-pycor and not break ]
  [
    set that-parcel-x [ parcel-x ] of patch x y
    set that-parcel-y [ parcel-y ] of patch x y
    ; jedu po patches dokud neni cislo parcely v X i v Y souradnici rozdilne
    if that-parcel-x != this-parcel-x and that-parcel-y != this-parcel-y
    [    
      set break true
    ]
    set x x + 1
    set y y + 1
  ]  
  if this-parcel-x != that-parcel-x and this-parcel-y != that-parcel-y
  [
    set vpravo-nahore patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]

  ; nalezneme parcelu vlevo nahore ... tj. odecitanim X a pricitanim Y
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ x >= min-pxcor and y <= max-pycor and not break ]
  [
    set that-parcel-x [ parcel-x ] of patch x y
    set that-parcel-y [ parcel-y ] of patch x y
    ; jedu po patches dokud neni cislo parcely v X i v Y souradnici rozdilne
    if that-parcel-x != this-parcel-x and that-parcel-y != this-parcel-y
    [    
      set break true
    ]
    set x x - 1
    set y y + 1
  ]  
  if this-parcel-x != that-parcel-x and this-parcel-y != that-parcel-y
  [
    set vlevo-nahore patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]

  ; nalezneme parcelu vpravo dole ... tj. pricitam X a odecitanim Y
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ x <= max-pxcor and y >= min-pycor and not break ]
  [
    set that-parcel-x [ parcel-x ] of patch x y
    set that-parcel-y [ parcel-y ] of patch x y
    ; jedu po patches dokud neni cislo parcely v X i v Y souradnici rozdilne
    if that-parcel-x != this-parcel-x and that-parcel-y != this-parcel-y
    [    
      set break true
    ]
    set x x + 1
    set y y - 1
  ]  
  if this-parcel-x != that-parcel-x and this-parcel-y != that-parcel-y
  [
    set vpravo-dole patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]

  ; nalezneme parcelu vlevo dole ... tj. odecitanim X a odecitanim Y
  set that-parcel-x [ parcel-x ] of this-patch
  set that-parcel-y [ parcel-y ] of this-patch
  set x [ pxcor ] of this-patch
  set y [ pycor ] of this-patch
  set break false
  while [ x >= min-pxcor and y >= min-pycor and not break ]
  [
    set that-parcel-x [ parcel-x ] of patch x y
    set that-parcel-y [ parcel-y ] of patch x y
    ; jedu po patches dokud neni cislo parcely v X i v Y souradnici rozdilne
    if that-parcel-x != this-parcel-x and that-parcel-y != this-parcel-y
    [    
      set break true
    ]
    set x x - 1
    set y y - 1
  ]  
  if this-parcel-x != that-parcel-x and this-parcel-y != that-parcel-y
  [
    set vlevo-dole patches with [ parcel-x = that-parcel-x and parcel-y = that-parcel-y ]
  ]  

  report (list vlevo vpravo nahore dole vlevo-nahore vpravo-nahore vpravo-dole vlevo-dole)

end

; pro vsechny parcely najde jejich sousedy
; nastavuje sousedy pro kazdy patch
to setup-parcel-neighbors
  reset-timer 

  let x min-pxcor + deleni-x * 0.5
  while [ x <= max-pxcor ]
  [
    let y min-pycor + deleni-y * 0.5
    while [ y <= max-pycor ]
    [
      let sousedi parcel-neighbors patch x y
      let this-parcel-x [ parcel-x ] of patch x y
      let this-parcel-y [ parcel-y ] of patch x y
      
      ask patches with [ parcel-x = this-parcel-x and parcel-y = this-parcel-y ]
      [
        set left-neighbors item 0 sousedi
        set right-neighbors item 1 sousedi
        set up-neighbors item 2 sousedi
        set down-neighbors item 3 sousedi

        set left-top-neighbors item 4 sousedi
        set left-bottom-neighbors item 7 sousedi
        set right-top-neighbors item 5 sousedi
        set right-bottom-neighbors item 6 sousedi        
      ]
      set y y + deleni-y
    ]
    set x x + deleni-x
  ]
  
  print (word "setup-parcel-neighbors in " timer " s")
end

to clear-graph-from-tree
  foreach created-links
  [
    ask ?
    [
      die
    ]
  ]
end

to create-graph-from-tree

  let low-land-nodes get-nodes-from-lowlands
 
  foreach low-land-nodes
  [
    ask ?
    [
      let currentNode self
      ;foreach ( list left-neighbors right-neighbors up-neighbors down-neighbors left-top-neighbors left-bottom-neighbors right-top-neighbors right-bottom-neighbors )
      foreach ( list left-neighbors right-neighbors up-neighbors down-neighbors )
      [
        if any? ?
        [
          let thisParcel-x [ parcel-x ] of one-of ?
          let thisParcel-y [ parcel-y ] of one-of ?
          
          let thisNode nodes with [ node-parcel-x = thisParcel-x and node-parcel-y = thisParcel-y ]
          if any? thisNode
          [
            set thisNode one-of thisNode
            
            let thisLink link ([ who ] of currentNode) ([ who ] of thisNode)
            if thisLink = nobody
            [
              ask currentNode
              [
                create-link-with thisNode
                [
                  set created-links lput self created-links
                  set color yellow ;red
                ]                
              ]           
            ]            
          ]
        ]
      ]
   
      
      set size 10
    ]
  ]
end

to-report get-nodes-from-lowlands
  let result []

  ask nodes
  [
    if is-low-land?
    [
      set result lput self result
    ] 
  ]
  
  report result
end

to nodes-in-lowlands-in-parcel
  let low-land-nodes []
  
  foreach low-land-parcels
  [
    let n nodes with [ node-parcel-x = item 0 ? and node-parcel-y = item 1 ? ] 
    if any? n
    [
      set low-land-nodes lput one-of n low-land-nodes
    ]
  ]
  
  foreach low-land-nodes
  [
    ask ?
    [
      set size 10
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
205
10
729
555
-1
-1
2.0
1
10
1
1
1
0
0
0
1
0
256
0
256
0
0
1
ticks

CC-WINDOW
5
569
915
664
Command Center
0

BUTTON
10
10
73
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

MONITOR
11
48
82
93
NIL
min-height
17
1
11

MONITOR
11
95
86
140
NIL
max-height
17
1
11

MONITOR
11
448
93
493
width x height
(word world-width \"x\" world-height )
17
1
11

BUTTON
12
184
136
217
NIL
create-paths
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
741
11
843
44
NIL
mouse-down
T
1
T
TURTLE
NIL
NIL
NIL
NIL

MONITOR
11
502
93
547
deleni
(word round deleni-x \" \" round deleni-y )
0
1
11

MONITOR
101
503
186
548
max parcel
(word max-parcel-x \" \" max-parcel-y )
17
1
11

MONITOR
11
353
82
398
visited?
count patches with [ visited? ]
17
1
11

SWITCH
12
145
146
178
show-parcels?
show-parcels?
0
1
-1000

BUTTON
44
264
134
297
NIL
dijkstra-go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

MONITOR
101
449
158
494
nodes
count nodes
17
1
11

BUTTON
742
47
889
80
mouse shortest-path
mouse-down-get-shortest-path
T
1
T
TURTLE
NIL
NIL
NIL
NIL

BUTTON
744
163
906
196
NIL
create-graph-from-tree
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
749
213
901
246
NIL
clear-graph-from-tree
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

@#$#@#$#@
WHAT IS IT?
-----------
This section could give a general understanding of what the model is trying to show or explain.


HOW IT WORKS
------------
This section could explain what rules the agents use to create the overall behavior of the model.


HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
