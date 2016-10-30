(ns d3-in-reagent.core
  (:require
   [reagent.core :as reagent]
   [cljsjs.d3]
   ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Model

(defonce app-state
  (reagent/atom
   {:width 300
    :data  [{:x 5}
            {:x 2}
            {:x 3}]}))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Util Fns

(defn get-width [ratom]
  (:width @ratom))

(defn get-height [ratom]
  (let [width (get-width ratom)]
    (* 0.8 width)))

(defn get-data [ratom]
  (:data @ratom))


(defn randomize-data [ratom]
  (let [points-n (max 2 (rand-int 8))
        points   (range points-n)
        create-x (fn [] (max 1 (rand-int 5)))]
    (swap! ratom update :data
           (fn []
             (mapv #(hash-map :x (create-x))
                   points)))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Components

(defn btn-toggle-width [ratom]
  [:div
   [:button
    {:on-click #(swap! ratom update
                       :width (fn [width]
                                (if (= 300 width) 500 300)))}
    "Toggle width"]])


(defn btn-randomize-data [ratom]
  [:div
   [:button
    {:on-click #(randomize-data ratom)}
    "Randomize data"]])



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Viz

;; Container

(defn container-enter [ratom]
  (-> (js/d3.select "#barchart svg")
      (.append "g")
      (.attr "class" "container")))

(defn container-did-mount [ratom]
  (container-enter ratom))


;; Bars

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


;; Main

(defn viz-render [ratom]
  (let [width  (get-width ratom)
        height (get-height ratom)]
    [:div
     {:id "barchart"}

     [:svg
      {:width  width
       :height height}]]))

(defn viz-did-mount [ratom]
  (container-did-mount ratom)
  (bars-did-mount ratom))

(defn viz-did-update [ratom]
  (bars-did-update ratom))

(defn viz [ratom]
  (reagent/create-class
   {:reagent-render      #(viz-render ratom)
    :component-did-mount #(viz-did-mount ratom)
    :component-did-update #(viz-did-update ratom)}))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Page

(defn home []
  [:div
   [:h1 "Barchart"]
   [btn-toggle-width app-state]
   [btn-randomize-data app-state]
   [viz app-state]
   ])



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize App

(defn ^:export main []
  (reagent/render [home]
                  (.getElementById js/document "app")))
