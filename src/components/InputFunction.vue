<template>
  <section>
    <!-- <div class="row"> -->
    <div class="alert" style="width: 50%" v-if="errorMsg">
      <span class="closebtn" @click="errorMsg = null">&times;</span>
      <strong>Error!</strong> {{ errorMsg }}
    </div>
    <fieldset>
      <legend>Input Function:</legend>
      <form @submit.prevent>
        <div class="row">
          <div class="column" style="width: 35%">
            <fieldset>
              <legend>Simple Term:</legend>
              <div class="row">
                <div class="column">
                  <label for="coefficient">Coefficient: </label>
                  <input
                    type="number"
                    id="coefficient"
                    min="-10e10"
                    max="10e10"
                    v-model="simpleTerm.coefficient"
                  />
                </div>
                <div class="column">
                  <label for="degree">Degree: </label>
                  <input
                    type="number"
                    id="degree"
                    min="-10e10"
                    max="10e10"
                    v-model="simpleTerm.degree"
                  />
                </div>
              </div>
              <div class="row">
                <div class="column" style="width: 100%">
                  <div>
                    <label class="tooltip"
                      >New:<span class="tooltiptext">{{
                        newOrExistingToolTip
                      }}</span
                      ><input
                        type="checkbox"
                        v-model="addNewSimpleTermSelected"
                    /></label>
                    <button @click="addTerm('Simple')">Add</button>
                    <button @click="reset('Simple')">Reset</button>
                  </div>
                </div>
              </div>
            </fieldset>
          </div>
          <div class="column" style="width: 61%">
            <fieldset>
              <legend>Complex Term:</legend>
              <div class="row">
                <div class="column" style="width: 30%">
                  <label for="multiplier">Multiplier: </label>
                  <select
                    id="multiplier"
                    @change="multiplierChanged"
                    ref="multiplier"
                  >
                    <option v-for="(t, i) in listOfTerms" :key="t" :value="i">
                      {{ `Expr${zeroFill(i + 1)}` }}
                    </option>
                  </select>
                </div>
                <div class="column" style="width: 30%">
                  <label for="allFunctions">Function:</label>
                  <select
                    id="allFunctions"
                    @change="builtInFunctionChanged"
                    ref="allFunctions"
                  >
                    <option
                      v-for="(f, idx) of allFunctions"
                      :key="f"
                      :value="idx"
                      style="font-style: italic"
                    >
                      f(x):{{ f }}
                    </option>
                  </select>
                </div>
                <div class="column" style="width: 30%">
                  <label for="argument">Argument: </label>
                  <select
                    id="argument"
                    @change="argumentChanged"
                    ref="argument"
                  >
                    <option v-for="(t, i) in listOfTerms" :key="t" :value="i">
                      {{ `Expr${zeroFill(i + 1)}` }}
                    </option>
                  </select>
                </div>
              </div>
              <div class="row">
                <div class="column" style="width: 25%">
                  <label for="degree">Degree: </label>
                  <input
                    type="number"
                    id="degree"
                    min="-10e10"
                    max="10e10"
                    v-model="complexTerm.degree"
                  />
                </div>
                <!-- </div>
              <div class="row"> -->
                <div class="column" style="width: 75%">
                  <div>
                    <label class="tooltip"
                      >New:<span class="tooltiptext">{{
                        newOrExistingToolTip
                      }}</span
                      ><input
                        type="checkbox"
                        v-model="addNewComplexTermSelected"
                    /></label>
                    <button @click="addTerm('Complex')">Add</button>
                    <button @click="reset('Complex')">Reset</button>
                  </div>
                </div>
              </div>
            </fieldset>
          </div>
        </div>
        <div class="row">
          <fieldset>
            <legend>Scratch Pad:</legend>
            <div class="column" style="width: 68%">
              <textarea
                id="scratchpad"
                :value="formattedListOfTerms"
                ref="scratchpad"
                readonly="readonly"
                @select="setPolynomial"
              ></textarea>
            </div>
            <div class="column" style="width: 32%">
              <fieldset>
                <legend>Select Input Domain:</legend>
                <div>
                  <label for="low">Low x value: </label>
                  <input
                    type="number"
                    id="low"
                    min="-10e10"
                    max="10e10"
                    v-model="polynomial.lowX"
                  />
                </div>
                <div>
                  <label for="high">High x value: </label>
                  <input
                    type="number"
                    id="high"
                    min="-10e10"
                    max="10e10"
                    v-model="polynomial.highX"
                  />
                </div>
              </fieldset>
            </div>
          </fieldset>
          <fieldset>
            <legend>Plot and Play:</legend>
            <div class="column" style="width: 50%">
              <div>
                <label class="tooltip">
                  <strong>&#x222b; dx:</strong>
                  <span class="tooltiptext">{{
                    calculateAreaUnderToolTip
                  }}</span
                  ><input
                    type="checkbox"
                    v-model="calculateAreaUnderSelected" /></label
                >&nbsp;
                <label class="tooltip">
                  <strong>dy/dx:</strong>
                  <span class="tooltiptext">{{ slopeFunctionToolTip }}</span
                  ><input type="checkbox" v-model="slopeFunctionSelected"
                /></label>
              </div>
              <div>
                <button @click="plot">Plot Function</button>
                &nbsp;
                <label class="tooltip" for="functionColor"
                  ><strong>f(x): </strong
                  ><span class="tooltiptext">{{ color1ToolTip }}</span></label
                ><input id="functionColor" type="color" v-model="color1" />
                &nbsp;<label class="tooltip" for="dervivativeColor"
                  ><strong>f'(x): </strong
                  ><span class="tooltiptext">{{ color2ToolTip }}</span></label
                ><input
                  id="dervivativeColor"
                  :disabled="!slopeFunctionSelected"
                  type="color"
                  v-model="color2"
                />
              </div>
              <div>
                <button @click="zoomIn">Zoom ++</button>
                <button @click="zoomOut">Zoom --</button>
                <button @click="clear">Clear Out Everything</button>
              </div>
            </div>
            <div class="column" style="width: 40%">
              <textarea
                id="results"
                :value="resultMsg"
                ref="results"
                readonly="readonly"
              ></textarea>
            </div>
          </fieldset>
        </div>
      </form>
    </fieldset>
    <!-- </div> -->
  </section>
</template>
<script>
const SIMPLE = "Simple";
const COMPLEX = "Complex";

export default {
  emits: ["receive-function-to-plot", "receive-zoom", "receive-clear"],
  props: ["builtInFunctions", "area"],
  computed: {
    formattedListOfTerms: function () {
      return this.listOfTerms
        .map(
          (o, i) =>
            `Expr${this.zeroFill(i + 1)}: ` +
            o.map((u) => this.formatTerm(u)).join(" + ")
        )
        .join("\r\n");
    },
    resultMsg: function () {
      let e = this.result.expKey;
      let a = this.result.area === null ? "NA" : this.result.area.toFixed(1);
      //let d = !this.slopeFunctionSelected ? "f'(x): NA" : "f'(x) in red";
      if (e.length) {
        return `Domain: ${this.polynomial.lowX} <= x <= ${this.polynomial.highX}\nf(x): ${e}\n\u222bf(x)dx: ${a}\nUse the color scheme to identify f(x) and f'(x)\n`;
      }
      return "";
    },
  },
  watch: {
    area: function (newVal) {
      this.result.area = newVal;
    },
  },
  data: function () {
    return {
      errorMsg: null,
      result: { expKey: "", area: null, derivative: null },
      padding: 3,
      newOrExistingToolTip: "Add new or append to existing expression",
      calculateAreaUnderToolTip: "Calculate area under the function",
      slopeFunctionToolTip: "The rate of change of the function",
      color1ToolTip: "Select a color for plotting the function",
      color2ToolTip: "Select a color for plotting the derivative function",
      addNewSimpleTermSelected: false,
      addNewComplexTermSelected: false,
      calculateAreaUnderSelected: false,
      slopeFunctionSelected: false,
      listOfTerms: [[{ coefficient: 1, degree: 1, type: SIMPLE }]],
      termType: SIMPLE,
      polynomial: { lowX: -10, highX: 10, terms: [] },
      simpleTerm: {
        type: SIMPLE,
        coefficient: 1,
        degree: 1,
      },
      complexTerm: {
        type: COMPLEX,
        multiplier: [{ coefficient: 1, degree: 1, type: SIMPLE }],
        argument: [{ coefficient: 1, degree: 1, type: SIMPLE }],
        function: "sin",
        degree: 1,
      },
      allFunctions: this.builtInFunctions.trigFunctions
        .map((o) => o.key)
        .concat(this.builtInFunctions.expFunctions.map((o) => o.key)),
      color1: "#000000",
      color2: "#ff0000",
    };
  },

  methods: {
    setPolynomial: function (event) {
      //console.log("Setting ploynomial");
      let input = event.target;
      let start = input.selectionStart;

      // Obtain the index of the last selected character
      let finish = input.selectionEnd;
      if (start === 0 && finish === 0) return;
      // Obtain the selected text
      let sel = input.value.substring(start, finish);

      if (!/Expr\d+/.test(sel)) {
        let i = start;
        do {
          sel = input.value.substr(i, "Expr".length + this.padding);
          i--;
        } while (!/Expr\d+/.test(sel));
        //console.log("sel: " + sel);

        //console.dir(input);
        this.selectText(this.$refs["scratchpad"], sel);
      }
      let res = sel.match(/Expr(\d+)/);
      //console.log("res:" + res);

      this.polynomial.terms = [...this.listOfTerms[Number(res[1]) - 1]];
    },

    reset: function (type) {
      if (type === SIMPLE) {
        this.simpleTerm.coefficient = 1;
        this.simpleTerm.degree = 1;
        this.addNewSimpleTermSelected = false;
      } else {
        this.complexTerm.multiplier = this.listOfTerms[0];
        this.complexTerm.argument = this.listOfTerms[0];
        this.complexTerm.function = this.allFunctions[0];
        this.complexTerm.degree = 1;
        this.addNewComplexTermSelected = false;
        this.$refs["allFunctions"].selectedIndex = 0;
        this.$refs["argument"].selectedIndex = 0;
        this.$refs["multiplier"].selectedIndex = 0;
      }
      this.calculateAreaUnderSelected = false;
      this.slopeFunctionSelected = false;
      this.polynomial.lowX = -10;
      this.polynomial.highX = 10;
    },

    clear: function () {
      this.$emit("receive-clear");
      this.reset(SIMPLE);
      this.reset(SIMPLE);
      this.color1 = "#000000";
      this.color2 = "#ff0000";
      this.result.expKey = "";
      this.result.area = null;
      this.result.derivative = null;
    },

    plot: function () {
      this.$emit(
        "receive-function-to-plot",
        this.polynomial,
        this.calculateAreaUnderSelected,
        this.slopeFunctionSelected,
        this.color1,
        this.color2
      );
      //console.log(this.polynomial.terms.length);

      this.result.expKey = this.polynomial.terms
        .map((i) => this.formatTerm(i))
        .join(" + ");
      if (this.calculateAreaUnderSelected) this.result.area = this.area;
    },

    zoomIn: function () {
      this.$emit("receive-zoom", 1);
    },

    zoomOut: function () {
      this.$emit("receive-zoom", -1);
    },

    addTerm: function (type) {
      const termToBeAdded =
        type === SIMPLE
          ? {
              type: type,
              coefficient: this.simpleTerm.coefficient,
              degree: this.simpleTerm.degree,
            }
          : {
              type: type,
              degree: this.complexTerm.degree,
              argument: [...this.complexTerm.argument],
              multiplier: [...this.complexTerm.multiplier],
              function: this.complexTerm.function,
            };

      const addNew =
        type === SIMPLE
          ? this.addNewSimpleTermSelected
          : this.addNewComplexTermSelected;
      //console.log(termToBeAdded);
      if (this.listOfTerms.length > 0 && !addNew) {
        this.listOfTerms[this.listOfTerms.length - 1].push(termToBeAdded);
      } else {
        this.listOfTerms.push([termToBeAdded]);
      }
      this.reset(type);
    },

    builtInFunctionChanged: function (event) {
      this.complexTerm.function = this.allFunctions[event.target.selectedIndex];
    },

    multiplierChanged: function (event) {
      let text = `Expr${this.zeroFill(event.target.selectedIndex + 1)}`;
      this.selectText(this.$refs["scratchpad"], text);
      this.complexTerm.multiplier = [
        ...this.listOfTerms[event.target.selectedIndex],
      ];
    },

    argumentChanged: function (event) {
      let text = `Expr${this.zeroFill(event.target.selectedIndex + 1)}`;
      this.selectText(this.$refs["scratchpad"], text);
      this.complexTerm.argument = [
        ...this.listOfTerms[event.target.selectedIndex],
      ];
    },

    formatTerm: function (obj) {
      if (obj.type === SIMPLE) {
        if (obj.degree === 0) {
          return `${obj.coefficient}`;
        }
        return `${obj.coefficient < 0 ? "-" : ""}${
          Math.abs(obj.coefficient) !== 1 ? Math.abs(obj.coefficient) : ""
        }x${obj.degree !== 1 ? "^" + obj.degree : ""}`;
      } else {
        const m = obj.multiplier;
        const a = obj.argument;

        let s = `${obj.degree !== 1 ? "(" : ""}`;
        for (let i = 0; i < m.length; i++) {
          s = s.concat(this.formatTerm(m[i]));
          if (m.length - i > 1) s = s.concat(" + ");
        }
        s = s.concat(`${obj.function}(`);
        for (let i = 0; i < a.length; i++) {
          s = s.concat(this.formatTerm(a[i]));
          if (a.length - i > 1) s = s.concat(" + ");
        }
        s = s.concat(")");
        s = s.concat(`${obj.degree !== 1 ? ")^" + obj.degree : ""}`);
        return s;
      }
    },

    zeroFill: function (number) {
      var zeroes = new Array(this.padding + 1).join("0");
      return (zeroes + number).slice(-this.padding) + "";
    },

    selectText: function (input, text) {
      const start = input.value.indexOf(text);

      if ("selectionStart" in input) {
        input.selectionStart = start;
        input.selectionEnd = start + text.length;
        input.focus();
      } else {
        // Internet Explorer before version 9
        let inputRange = input.createTextRange();
        inputRange.moveStart("character", start);
        inputRange.collapse();
        inputRange.moveEnd("character", text.length);
        inputRange.select();
      }
    },
  },
};
</script>
<style scoped>
.alert {
  padding: 20px;
  background-color: #f44336;
  color: white;
  width: 30%;
  margin: auto;
}

.closebtn {
  margin-left: 15px;
  color: white;
  font-weight: bold;
  float: right;
  font-size: 22px;
  line-height: 20px;
  cursor: pointer;
  transition: 0.3s;
}

.closebtn:hover {
  color: black;
}
.tooltip {
  position: relative;
  display: inline-block;
}

.tooltip .tooltiptext {
  visibility: hidden;
  width: 120px;
  background-color: black;
  color: #fff;
  text-align: center;
  border-radius: 6px;
  padding: 5px 0;

  /* Position the tooltip */
  position: absolute;
  left: 20px;
  bottom: 20px;
  z-index: 1;
}

.tooltip:hover .tooltiptext {
  visibility: visible;
}

fieldset {
  width: 90%;
  border: solid 1px blue;
  background-color: yellow !important;
}

legend {
  text-align: left;
  font-size: small;
  color: blue;
}

label {
  font-size: small;
  color: blue;
}

div {
  text-align: left;
}

button {
  background-color: aqua;
}

select option {
  background-color: #aa99bb;
}

#scratchpad {
  width: 360px;
  height: 110px;
  padding: 6px 10px;
  box-sizing: border-box;
  border: 2px solid #ccc;
  border-radius: 4px;
  background-color: #f8f8f8;
  font-size: 14px;
  --font-style: italic;
  resize: none;
}

#results {
  width: 262px;
  height: 100px;
  padding: 6px 10px;
  box-sizing: border-box;
  border: 2px solid #ccc;
  border-radius: 4px;
  background-color: #f8f8f8;
  font-size: 14px;
  resize: none;
  --color: red;
}
</style>