{:title "D3 in Reagent"
 :layout :post
 :tags  ["clojurescript" "reagent" "d3"]
 :toc true
 :issue-id "3"}

**Goal**: Share an example of a dynamic barchart that showcases how to
use d3's [General Update Pattern](https://bl.ocks.org/mbostock/3808218) with reagent's [form-3](https://github.com/Day8/re-frame/wiki/Creating-Reagent-Components#form-3-a-class-with-life-cycle-methods) component. Note,
detailing how to use d3 itself is **not** a goal.

-   [d3](https://d3js.org) is an amazing visualization library written in javascript.
-   [Reagent](https://github.com/reagent-project/reagent) is a clojurescript wrapper around facebook's [react](https://facebook.github.io/react/).

**Intended Audience**: Intermediate clojurescript / d3 developers.

**[Demo](https://gadfly361.github.io/gadfly-blog/demos/2016-10-22-d3-in-reagent/index.html)**, **[Source](https://github.com/gadfly361/gadfly-blog/tree/master/code/2016-10-22-d3-in-reagent)**

For this post, we are going to start with [reagent-cookbook-template](https://github.com/gadfly361/reagent-cookbook-template),
which is useful for demonstration purposes. However, it is **not** a
good template for development (I'd recommend [reagent-figwheel](https://github.com/gadfly361/reagent-figwheel)
or [re-frame-template](https://github.com/Day8/re-frame-template) instead).

## **Step 1** Create application

    lein new rc d3-in-reagent

You should see an output like this:

    ├── project.clj
    ├── resources
    │   └── public
    │       └── index.html
    └── src
        └── cljs
    	└── d3_in_reagent
    	    └── core.cljs

## **Step 2** Add d3 dependency to your project

There are [several ways](https://github.com/lambdaisland/thirdpartyjs) to add d3 to your project; we are going to use [cljsjs](https://github.com/cljsjs/packages).
Open `project.clj` and add d3 to the dependencies vector.

    :dependencies [[org.clojure/clojure "1.7.0"]
    	       [org.clojure/clojurescript "1.7.122"]
    	       [reagent "0.5.1"]
    	       [cljsjs/d3 "4.2.2-0"] ;; <-- ATTENTION
    	       ]

Open `core.cljs` and require d3.

    (ns d3-in-reagent.core
      (:require
       [reagent.core :as reagent]
       [cljsjs.d3] ;; <-- ATTENTION
       ))

## **Step 3** Create SVG element

To make our barchart, we need to put an SVG element on our page.

    (defn viz []
      [:div
       {:id "barchart"}
    
       [:svg
        {:width  300
         :height 240}]])
    
    
    (defn home []
      [:div
       [:h1 "Barchart"]
       [viz]])

At this point, run your application (`lein cljsbuild once prod`, and
then open `resources/public/index.html`) to verify that you have an
svg on the page. You should see:

    <svg width="300" height="240" data-reactid=".0.1.0"></svg>

## **Step 4** Make height and width dynamic

However, I do not like the statically defined height and width. From
experience, I have found that creating functions to generate the
height and width works well for making responsive visualizations.

    (defonce app-state
      (reagent/atom
       {:width 300}))
    
    
    (defn get-width [ratom]
      (:width @ratom))
    
    (defn get-height [ratom]
      (let [width (get-width ratom)]
        (* 0.8 width)))
    
    
    (defn viz [ratom]
      (let [width  (get-width ratom)
    	height (get-height ratom)]
        [:div
         {:id "barchart"}
    
         [:svg
          {:width  width
           :height height}]]))

We can test this out by creating a toggle-width button.

    (defn btn-toggle-width [ratom]
      [:div
       [:button
        {:on-click #(swap! ratom update
    		       :width (fn [width]
    				(if (= 300 width) 500 300)))}
        "Toggle width"]])
    
    (defn home []
      [:div
       [:h1 "Barchart"]
       [btn-toggle-width app-state]
       [viz app-state]
       ])

If you click the button, the svg should toggle between:

    <svg width="300" height="240" data-reactid=".0.2.0"></svg>

    <svg width="500" height="400" data-reactid=".0.2.0"></svg>

## **Step 5** Create a containing 'g' element

Now that we have a dynamically sized svg element, let's add stuff to
it! To start, we can add a simple `g` element to act as a container
for other svg elements.

    svg
    └── g.container

**Pause**

Ok, I lied. It isn't going to be all that simple. If you haven't done
so, familiarize yourself with d3's [General Update Pattern](https://bl.ocks.org/mbostock/3808218) and
reagent's [form-3](https://github.com/Day8/re-frame/wiki/Creating-Reagent-Components#form-3-a-class-with-life-cycle-methods) component.

From the d3 world, we care about:

-   `enter -> update -> exit`

From the reagent/react world, we care about:

-   `reagent-render -> component-did-mount -> component-did-update`

Since we are working with two different worlds, I recommend enforcing
a strict naming convention:

-   d3 world: \*-enter, \*-update, \*-exit
-   reagent/react world: \*-render, \*-did-mount, \*-did-update

    (defn container-enter [ratom]
      (-> (js/d3.select "#barchart svg")
          (.append "g")
          (.attr "class" "container")))
    
    (defn container-did-mount [ratom]
      (container-enter ratom))

    (defn viz-render [ratom]
      (let [width  (get-width ratom)
    	height (get-height ratom)]
        [:div
         {:id "barchart"}
    
         [:svg
          {:width  width
           :height height}]]))
    
    (defn viz-did-mount [ratom]
      (container-did-mount ratom))
    
    (defn viz [ratom]
      (reagent/create-class
       {:reagent-render      #(viz-render ratom)
        :component-did-mount #(viz-did-mount ratom)}))

Let's recap the order of events between d3 and reagent.

1.  `viz` component calls its render function, `viz-render`
    -   places svg element on the DOM
2.  `viz` component calls its did-mount function, `viz-did-mount`
    -   `viz-did-mount` calls `container-did-mount`
    -   `container-did-mount` calls `container-enter`
    -   `container-enter` grabs the svg element and appends a `g` element.

## **Step 6** Add bars

Let's add some data that we can use to generate the bars in our chart.

    (defonce app-state
      (reagent/atom
       {:width 300
        :data  [{:x 1}
    	    {:x 2}
    	    {:x 3}]}))
    
    (defn get-data [ratom]
      (:data @ratom))

Next, let's add the bars to our svg with the previously discussed
naming convention. By the end, our svg structure will look like this.

    svg
    └── g.container
        └── g.bars
    	└── rect
    	└── rect
    	└── rect

*Note: Since this is not a d3 tutorial, I am making the assumption
that the d3 bits below make sense.*

    (defn bars-enter [ratom]
      (let [data (get-data ratom)]
        (-> (js/d3.select "#barchart svg .container .bars")
    	(.selectAll "rect")
    	(.data (clj->js data))
    	.enter
    	(.append "rect"))))
    
    (defn bars-update [ratom]
      (let [width   (get-width ratom)
    	height  (get-height ratom)
    	data    (get-data ratom)
    	data-n  (count data)
    	rect-height (/ height data-n)
    	x-scale (-> js/d3
    		    .scaleLinear
    		    (.domain #js [0 5])
    		    (.range #js [0 width]))]
        (-> (js/d3.select "#barchart svg .container .bars")
    	(.selectAll "rect")
    	(.data (clj->js data))
    	(.attr "fill" "green")
    	(.attr "x" (x-scale 0))
    	(.attr "y" (fn [_ i]
    		     (* i rect-height)))
    	(.attr "height" (- rect-height 1))
    	(.attr "width" (fn [d]
    			 (x-scale (aget d "x")))))))
    
    (defn bars-exit [ratom]
      (let [data (get-data ratom)]
        (-> (js/d3.select "#barchart svg .container .bars")
    	(.selectAll "rect")
    	(.data (clj->js data))
    	.exit
    	.remove)))
    
    
    (defn bars-did-update [ratom]
      (bars-enter ratom)
      (bars-update ratom)
      (bars-exit ratom))
    
    (defn bars-did-mount [ratom]
      (-> (js/d3.select "#barchart svg .container")
          (.append "g")
          (.attr "class" "bars"))
      (bars-did-update ratom))

Hopefully, at this point the separation of the d3 world, and the
reagent/react world is clear.

d3 world:

-   bars-enter
-   bars-update
-   bars-exit

reagent/react world:

-   bars-did-update
-   bars-did-mount

It should be noted that `bars-did-update` and `bars-did-mount` are
*almost* the same. However, the difference is important to
understand. `bars-did-mount` will only ever be called once, right
after the component has mounted. `bars-did-update` will be called on
every subsequent render of our component.  If we had placed the
following:

    (-> (js/d3.select "#barchart svg .container")
        (.append "g")
        (.attr "class" "bars"))

inside of `bars-did-update`, we would have created a **new** `g` element
every time the component updated &#x2026; eek!

Now we can add the bars to our svg, as follows.

    (defn viz-did-mount [ratom]
      ;; order matters here
      (container-did-mount ratom)
      (bars-did-mount ratom))
    
    (defn viz-did-update [ratom]
      (bars-did-update ratom))
    
    (defn viz [ratom]
      (reagent/create-class
       {:reagent-render       #(viz-render ratom)
        :component-did-mount  #(viz-did-mount ratom)
        :component-did-update #(viz-did-update ratom)}))

## **Step 7** Make bars dynamic

We have actually already written the code to make the bars dynamic!
However, to see it, let's add a button that will create random data.

    (defn randomize-data [ratom]
      (let [points-n (max 2 (rand-int 8))
    	points   (range points-n)
    	create-x (fn [] (max 1 (rand-int 5)))]
        (swap! ratom update :data
    	   (fn []
    	     (mapv #(hash-map :x (create-x))
    		   points)))))
    
    (defn btn-randomize-data [ratom]
      [:div
       [:button
        {:on-click #(randomize-data ratom)}
        "Randomize data"]])

    (defn home []
      [:div
       [:h1 "Barchart"]
       [btn-toggle-width app-state]
       [btn-randomize-data app-state]
       [viz app-state]
       ])

## Thanks for Reading

**[Demo](https://gadfly361.github.io/gadfly-blog/demos/2016-10-22-d3-in-reagent/index.html)**, **[Source](https://github.com/gadfly361/gadfly-blog/tree/master/code/2016-10-22-d3-in-reagent)**

If you have any questions, I can be reached in the #reagent channel of
the [clojurians](http://clojurians.net/) slack group.

Cheers, gadfly361
