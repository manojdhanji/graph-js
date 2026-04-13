<template>
  <main class="layout">
    <section class="input-panel" aria-labelledby="input-heading">
      <h2 id="input-heading" class="sr-only">Function Input Panel</h2>

      <InputFunction :builtInFunctions="builtInFunctions" :area="area" @receive-function-to-plot="receiveFunction"
        @receive-zoom="zoom" @receive-clear="clear" />
    </section>

    <section class="graph-panel" aria-labelledby="graph-heading">
      <h2 id="graph-heading" class="sr-only">Graph Display Panel</h2>

      <CartesianPlane :polynomial="polynomial" :calculateAreaUnderSelected="calculateAreaUnderSelected"
        :slopeFunctionSelected="slopeFunctionSelected" :color1="color1" :color2="color2"
        :builtInFunctions="builtInFunctions" :zoom="inOut" :clearFlag="clearFlag"
        @receive-area-calculated="areaUnderFunction" />
    </section>
  </main>
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
          { key: "pow", value: Math.pow },
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
/* Global box sizing */
* {
  box-sizing: border-box;
}

/* Screen-reader-only utility */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

/* Flexbox layout replacing .row + .column floats */
.layout {
  display: flex;
  gap: 1rem;
  padding: 1rem;
}

/* Left panel (InputFunction) */
.input-panel {
  flex: 0 0 40%; /* matches your original width: 40% */
}

/* Right panel (CartesianPlane) */
.graph-panel {
  flex: 0 0 60%; /* matches your original width: 60% */
}

/* Original global app styles — keep them */
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 20px;
}
</style>
