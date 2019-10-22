
HiFPTuner

paper: Exploiting community structure for floating-point precision tuning, ISSTA'18

INSTALL
-------------------------------------------------------
Prerequisites:
    1. llvm 3.0 & 3.8

    2. Precimonious
        repo.: https://github.com/ucd-plse/precimonious 

    3. NetworkX 2.2 python package
        install: pip install 'networkx==2.2'
        repo.:   https://github.com/networkx/networkx

    4. Community python package
        install: pip install python-louvain
        repo.: https://bitbucket.org/taynaud/python-louvain

    5. pygraphviz and other graph python packages
        pip install graphviz
        pip install pygraphviz
        apt-get install python-matplotlib
        apt-get install libgraphviz-dev
        apt-get install python-dev

Install HiFPTuner:
    1. go to path/to/HiFPTuner/precimonious/logging
    2. make clean; make
    3. switch to llvm 3.8
       3.1 modify ~/.bashrc: $LLVM_VERSION=llvm-3.8
       3.2 . ~/.bashrc
    4. go to path/to/HiFPTuner/src/varDeps
    5. make clean; make


USAGE
-------------------------------------------------------
example simpsons

    GENERATE HiFPTuner config files
        "topolOrder_pro.json"
        "partition.json"
        "sorted_partition.json"
        "varDepGraph_pro.png"
    ---------------------------------    
    1. $cd path/to/HiFPTuner/examples/simpsons
 
    2. generate llvm_3.0 bitcode file
        $switch to llvm 3.0
        $clang -c -emit-llvm simpsons.c -o simpsons.bc
        $path/to/HiFPTuner/scripts/compile.sh simpsons.bc

    3. Run llvm analysis and transformation passes to attain the dependence graph
        $switch to llvm 3.8
        $path/to/HiFPTuner/scripts/analyze.sh json_simpsons.bc
        (Check outputs: "varDepPairs_pro.json" and "edgeProfilingOut.json" for the dependece pairs and edge weights.)

    4. Run Networkx and community packages to attain the unsorted and sorted hierarchy
        $path/to/HiFPTuner/scripts/config.sh
        (Check outputs: "partition.json", "sorted_partition.json" and "topolOrder_pro.json" for the unsorted hierarchy, sorted hierarchy and the topological ordered variable list)
        (Also, check varDepGraph_pro.png for the visualized dependence graph)


    GENERATE sorted PRECIMONIOUS search and config files
        "sorted_search_TEST.json"
        "sorted_config_TEST.json" 
    -----------------------------------------------------
    $path/to/HiFPTuner/scripts/sort.sh search_simpsons.json config_simpsons.json topolOrder_pro.json
    (Check outputs: "sorted_search_simpsons.json" and "sorted_config_simpsons.json" for the sorted PRECIMONIOUS search and config files)


    Dynamic TUNING
    --------------
    Firstly, $cp path/to/HiFPTuner/src/preci_dd/* path/to/precimonious/scripts/ AND,
             $switch to llvm 3.0

    1. "sorting"
        $python path/to/HiFPTuner/precimonious/scripts/dd2.py simpsons.bc sorted_search_simpsons.json sorted_config_simpsons.json

    2. "grouping"
        $python -O path/to/HiFPTuner/precimonious/scripts/dd2_prof.py simpsons.bc search_simpsons.json config_simpsons.json partition.json

    3. "sorted_grouping"
        $python -O path/to/HiFPTuner/precimonious/scripts/dd2_prof.py simpsons.bc search_simpsons.json config_simpsons.json sorted_partition.json