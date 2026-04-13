<template>
  <section class="input-function">
    <fieldset>
      <legend>Input Function:</legend>
      <form @submit.prevent>
        <!-- SIMPLE + COMPLEX TERM PANELS -->
        <div class="layout">
          <!-- SIMPLE TERM -->
          <section class="panel simple-term-panel">
            <fieldset>
              <legend>Simple Term:</legend>
              <div class="layout">
                <div class="panel">
                  <label for="coefficient">Coefficient:</label>
                  <input type="number" id="coefficient" min="-10e10" max="10e10" v-model="simpleTerm.coefficient" />
                </div>
                <div class="panel">
                  <label for="sdegree">Degree:</label>
                  <input type="number" id="sdegree" min="-10e10" max="10e10" v-model="simpleTerm.degree" />
                </div>
              </div>
              <div class="layout">
                <div class="panel">
                  <label class="tooltip">
                    New:
                    <span class="tooltiptext">{{ newOrExistingToolTip }}</span>
                    <input type="checkbox" v-model="addNewSimpleTermSelected" />
                  </label>
                  <div class="button-row">
                    <button @click="addTerm('Simple')">Add</button>
                    <button @click="reset('Simple')">Reset</button>
                  </div>
                </div>
              </div>
            </fieldset>
          </section>
          <!-- COMPLEX TERM -->
          <section class="panel complex-term-panel">
            <fieldset>
              <legend>Complex Term:</legend>
              <div class="layout">
                <div class="panel">
                  <label for="multiplier">Multiplier:</label>
                  <select id="multiplier" @change="multiplierChanged" ref="multiplier">
                    <option v-for="(t, i) in listOfTerms" :key="t" :value="i">
                      {{ `Expr${zeroFill(i + 1)}` }}
                    </option>
                  </select>
                </div>
                <div class="panel">
                  <label for="allFunctions">Function:</label>
                  <select id="allFunctions" @change="builtInFunctionChanged" ref="allFunctions">
                    <option v-for="(f, idx) in allFunctions" :key="f" :value="idx" style="font-style: italic">
                      f(x):{{ f }}
                    </option>
                  </select>
                </div>
                <div class="panel">
                  <label for="argument">Argument:</label>
                  <select id="argument" @change="argumentChanged" ref="argument">
                    <option v-for="(t, i) in listOfTerms" :key="t" :value="i">
                      {{ `Expr${zeroFill(i + 1)}` }}
                    </option>
                  </select>
                </div>
              </div>
              <div class="layout">
                <div class="panel small">
                  <label for="cdegree">Degree:</label>
                  <input type="number" id="cdegree" min="-10e10" max="10e10" v-model="complexTerm.degree" />
                </div>
                <div class="panel large">
                  <label class="tooltip">
                    New:
                    <span class="tooltiptext">{{ newOrExistingToolTip }}</span>
                    <input type="checkbox" v-model="addNewComplexTermSelected" />
                  </label>
                  <div class="button-row">
                    <button @click="addTerm('Complex')">Add</button>
                    <button @click="reset('Complex')">Reset</button>
                  </div>
                </div>
              </div>
            </fieldset>
          </section>
        </div>
        <!-- SCRATCHPAD + DOMAIN -->
        <fieldset>
          <legend>Scratch Pad:</legend>
          <div class="layout">
            <section class="panel scratchpad-panel">
              <textarea id="scratchpad" :value="formattedListOfTerms" ref="scratchpad" readonly
                @select="setPolynomial"></textarea>
            </section>
            <section class="panel domain-panel">
              <fieldset>
                <legend>Select Input Domain:</legend>
                <label for="low">Low x value:</label>
                <input type="number" id="low" v-model="polynomial.lowX" />
                <label for="high">High x value:</label>
                <input type="number" id="high" v-model="polynomial.highX" />
              </fieldset>
            </section>
          </div>
        </fieldset>
        <!-- PLOT + RESULTS -->
        <fieldset>
          <legend>Plot and Play:</legend>
          <div class="layout">
            <section class="panel plot-controls">
              <label class="tooltip">
                <strong>&#x222b; dx:</strong>
                <span class="tooltiptext">{{ calculateAreaUnderToolTip }}</span>
                <input type="checkbox" v-model="calculateAreaUnderSelected" />
              </label>
              <label class="tooltip">
                <strong>dy/dx:</strong>
                <span class="tooltiptext">{{ slopeFunctionToolTip }}</span>
                <input type="checkbox" v-model="slopeFunctionSelected" />
              </label>
              <div>
                <button @click="plot">Plot Function</button>
                <label class="tooltip" for="functionColor">
                  <strong>f(x):</strong>
                  <span class="tooltiptext">{{ color1ToolTip }}</span>
                </label>
                <input id="functionColor" type="color" v-model="color1" />
                <label class="tooltip" for="derivativeColor">
                  <strong>f'(x):</strong>
                  <span class="tooltiptext">{{ color2ToolTip }}</span>
                </label>
                <input id="derivativeColor" type="color" :disabled="!slopeFunctionSelected" v-model="color2" />
              </div>
              <div>
                <button @click="zoomIn">Zoom ++</button>
                <button @click="zoomOut">Zoom --</button>
                <button @click="clear">Clear Out Everything</button>
              </div>
            </section>
            <section class="panel results-panel">
              <textarea id="results" :value="resultMsg" ref="results" readonly></textarea>
            </section>
          </div>
        </fieldset>
      </form>
    </fieldset>
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

        this.selectText(this.$refs["scratchpad"], sel);
      }
      let res = sel.match(/Expr(\d+)/);

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
      this.reset(COMPLEX);
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
    formatTerm(obj) {
      return obj.type === SIMPLE
        ? this.formatSimple(obj)
        : this.formatComposite(obj);
    },
    formatSimple(obj) {
      if (obj.degree === 0) {
        return `${obj.coefficient}`;
      }
      const sign = obj.coefficient < 0 ? "-" : "";
      const coeff = Math.abs(obj.coefficient) === 1 ? "" : Math.abs(obj.coefficient);
      const degree = obj.degree === 1 ? "" : `^${obj.degree}`;
      return `${sign}${coeff}x${degree}`;
    },
    formatComposite(obj) {
      const multiplier = this.joinTerms(obj.multiplier);
      const argument = this.joinTerms(obj.argument);
      const open = obj.degree === 1 ? "" : "(";
      const close = obj.degree === 1 ? "" : `)^${obj.degree}`;
      const fn = obj.function === "pow"
        ? `${obj.function}(x, `
        : `${obj.function}(`;

      return `${open}${multiplier} ${fn}${argument})${close}`;
    },
    joinTerms(list) {
      return list.map(t => this.formatTerm(t)).join(" + ");
    },
    zeroFill: function (number) {
      let zeroes = new Array(this.padding + 1).join("0");
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

/* FLEXBOX LAYOUT */
.layout {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.panel {
  flex: 1;
}

/* Match original proportions */
.simple-term-panel {
  flex: 0 0 35%;
}

.complex-term-panel {
  flex: 0 0 61%;
}

.scratchpad-panel {
  flex: 0 0 68%;
}

.domain-panel {
  flex: 0 0 32%;
}

.plot-controls {
  flex: 0 0 50%;
}

.results-panel {
  flex: 0 0 40%;
}

/* FIELDSETS */
fieldset {
  width: 100%;
  border: 1px solid #d0d7de;
  background-color: #f9f9f9;
  padding: 1rem;
  border-radius: 6px;
}

legend {
  font-size: 0.9rem;
  font-weight: 600;
  color: #1e3a8a;
  padding: 0 0.25rem;
}

/* LABELS */
label {
  font-size: 0.85rem;
  color: #1e3a8a;
  display: inline-block;
  margin-bottom: 0.25rem;
}

/* TOOLTIP */
.tooltip {
  position: relative;
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
}

.tooltip .tooltiptext {
  visibility: hidden;
  width: max-content;
  max-width: 180px;
  background-color: #000;
  color: #fff;
  text-align: center;
  border-radius: 6px;
  padding: 0.4rem 0.6rem;
  font-size: 0.75rem;

  position: absolute;
  left: 0;
  top: 100%;
  margin-top: 0.25rem;
  z-index: 10;

  opacity: 0;
  transition: opacity 0.2s ease;
}

.tooltip:hover .tooltiptext {
  visibility: visible;
  opacity: 1;
}

/* BUTTONS */
button {
  background-color: #f3f4f6;
  color: #111827;
  border: 1px solid #d1d5db;
  padding: 0.45rem 0.9rem;
  border-radius: 6px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: background-color 0.15s ease, border-color 0.15s ease;
}

button:hover {
  background-color: #e5e7eb;
  border-color: #9ca3af;
}

/* SELECT OPTIONS */
select option {
  background-color: #f3f4f6;
  /* soft gray */
  color: #111827;
  /* deep gray */
}

/* TEXTAREAS */
#scratchpad,
#results {
  width: 100%;
  padding: 0.5rem;
  border: 2px solid #ccc;
  border-radius: 4px;
  background-color: #f8f8f8;
  font-size: 0.9rem;
  resize: none;
}

#scratchpad {
  height: 110px;
  font-style: italic;
}

#results {
  height: 100px;
  color: red;
}

/* ALERT (unchanged except modernized spacing) */
.alert {
  padding: 1rem;
  background-color: #d32f2f;
  color: white;
  width: 30%;
  margin: 1rem auto;
  border-radius: 4px;
}

.closebtn {
  margin-left: 1rem;
  color: white;
  font-weight: bold;
  float: right;
  font-size: 1.4rem;
  line-height: 1;
  cursor: pointer;
  transition: color 0.3s ease;
}

.closebtn:hover {
  color: black;
}
</style>