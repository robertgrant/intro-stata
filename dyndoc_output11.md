<html>
<head>
<style>
  body{ font-family:sans-serif; }
</style>
</head>

<body>

MPG facts from 1978
======

We will now analyse the **auto.dta** file.

<<dd_do: quietly>>
sysuse auto.dta, clear
scatter price mpg, name(scatter1, replace)
scatter price trunk, name(scatter2, replace)
scatter price headroom, name(scatter3, replace)
summarize mpg
<</dd_do>>
The mean MPG was <<dd_display: %8.2f r(mean)>>

This is based on cars like the:

* Buick Regal
* Renault Le Car
* Datsun 810

The top 5 for fuel efficiency were:

1.  VW Diesel
1.  Datsun 210
1.  Subaru
1.  Plym. Champ
1.  Toyota Corolla

Choose which scatterplot to display:

<button onclick="showGraph1()">Price v MPG</button>
<button onclick="showGraph2()">Price v Trunk</button>
<button onclick="showGraph3()">Price v Headroom</button>

<<dd_graph: graphname(scatter1)>>

<<dd_graph: graphname(scatter2)>>

<<dd_graph: graphname(scatter3)>>

<script>
  document.querySelectorAll("img")[0].setAttribute("width",100);
  document.querySelectorAll("img")[1].setAttribute("width",100);
  document.querySelectorAll("img")[2].setAttribute("width",100);
  function showGraph1() {
    document.querySelectorAll("img")[0].setAttribute("width",600);
    document.querySelectorAll("img")[1].setAttribute("width",100);
    document.querySelectorAll("img")[2].setAttribute("width",100);
  }
  function showGraph2() {
    document.querySelectorAll("img")[0].setAttribute("width",100);
    document.querySelectorAll("img")[1].setAttribute("width",600);
    document.querySelectorAll("img")[2].setAttribute("width",100);
  }
  function showGraph3() {
    document.querySelectorAll("img")[0].setAttribute("width",100);
    document.querySelectorAll("img")[1].setAttribute("width",100);
    document.querySelectorAll("img")[2].setAttribute("width",600);
  }
</script>
</body>
</html>
