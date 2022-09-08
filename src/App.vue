<template>
  <div class="row">
    <div class="column" style="width: 40%">
      <InputFunction
        :builtInFunctions="builtInFunctions"
        :area="area"
        @receive-function-to-plot="receiveFunction"
        @receive-zoom="zoom"
        @receive-clear="clear"
      />
    </div>
    <div class="column" style="width: 60%">
      <CartesianPlane
        :polynomial="polynomial"
        :calculateAreaUnderSelected="calculateAreaUnderSelected"
        :slopeFunctionSelected="slopeFunctionSelected"
        :color1="color1"
        :color2="color2"
        :builtInFunctions="builtInFunctions"
        :zoom="inOut"
        :clearFlag="clearFlag"
        @receive-area-calculated="areaUnderFunction"
      />
    </div>
  </div>
</template>

<script>
import CartesianPlane from "./components/CartesianPlane.vue";
import InputFunction from "./components/InputFunction.vue";

export default {
  name: "Graph-Plotter",

  data: function () {
    return {
      inOut: 0,
      clearFlag: false,
      area: null,
      polynomial: {},
      calculateAreaUnderSelected: false,
      slopeFunctionSelected: false,
      color1: null,
      color2: null,
      builtInFunctions: {
        trigFunctions: [
          { key: "sin", value: Math.sin },
          { key: "sinh", value: Math.sinh },
          { key: "cos", value: Math.cos },
          { key: "cosh", value: Math.cosh },
          { key: "tan", value: Math.tan },
          { key: "tanh", value: Math.tanh },
        ],
        expFunctions: [
          { key: "ln", value: Math.log },
          { key: "log", value: Math.log10 },
          { key: "exp", value: Math.exp },
        ],
      },
    };
  },
  components: {
    CartesianPlane,
    InputFunction,
  },
  methods: {
    receiveFunction: function (
      polynomial,
      calculateAreaUnderSelected,
      slopeFunctionSelected,
      color1,
      color2
    ) {
      console.log("receiveFunction");
      this.polynomial = {
        highX: polynomial.highX,
        lowX: polynomial.lowX,
        terms: [...polynomial.terms],
      };
      this.calculateAreaUnderSelected = calculateAreaUnderSelected;
      this.slopeFunctionSelected = slopeFunctionSelected;
      this.color1 = color1;
      this.color2 = color2;
    },
    zoom: function (inOut) {
      let temp = this.inOut + inOut;
      if (temp >= 0 && temp <= 4) this.inOut += inOut;
    },
    clear: function () {
      console.log("Clear Flag");
      this.clearFlag = !this.clearFlag;
    },
    areaUnderFunction: function (area) {
      this.area = area;
    },
  },
};
</script>

<style>
* {
  box-sizing: border-box;
}

.column {
  float: left;
  width: 50%;
  padding: 2px;
}

/* Clearfix (clear floats) */
.row::after {
  content: "";
  clear: both;
  display: table;
}

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 20px;
}
</style>
