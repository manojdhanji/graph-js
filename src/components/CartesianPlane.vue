<template>

  <canvas id="myCanvas" :width="xLength" :height="yLength" ref="canvas">
    Your browser does not support HTML canvas. The graph cannot be displayed.
  </canvas>
</template>
<script>
const dx = 0.01;
const lightStroke = 0.3;
const heavyStroke = 0.9;
const zoomFactor = 4;

function createLines(ctx, scaleFactor, axisLength, callback) {
  let mid = axisLength / 2;
  for (let i = 0; i <= axisLength; i += scaleFactor) {
    ctx.beginPath();
    ctx.lineWidth = lightStroke;
    if (i === mid || i === 0 || i === axisLength) ctx.lineWidth = heavyStroke;
    callback(i, ctx);
    ctx.strokeStyle = "#000000";
    ctx.stroke();
  }
}
export default {
  mounted: function () {
    this.drawGrid();
  },
  props: [
    "polynomial",
    "calculateAreaUnderSelected",
    "slopeFunctionSelected",
    "color1",
    "color2",
    "builtInFunctions",
    "zoom",
    "clearFlag",
  ],
  emits: ["receive-area-calculated", "reset-clear-flag"],
  data: function () {
    return {
      scaleFactor: zoomFactor,
      xLength: 1024,
      yLength: 896,
    };
  },
  methods: {
    drawGrid: function () {
      const ctx = this.$refs.canvas.getContext("2d");
      ctx.clearRect(0, 0, this.xLength, this.yLength);
      createLines(ctx, this.scaleFactor, this.yLength, (i, ctx) => {
        ctx.moveTo(0, i);
        ctx.lineTo(this.xLength, i);
      });
      createLines(ctx, this.scaleFactor, this.xLength, (i, ctx) => {
        ctx.moveTo(i, 0);
        ctx.lineTo(i, this.yLength);
      });
    },
    fx: function (x, terms) {
      let y = 0;

      for (const t of terms) {
        y += t.type === "Simple"
          ? this.evalSimpleTerm(x, t)
          : this.evalCompositeTerm(x, t);
      }

      if (!Number.isFinite(y)) {
        throw new RangeError("Function evaluation resulted in NaN");
      }

      return y;
    },
    evalSimpleTerm: function (x, term) {
      return term.coefficient * Math.pow(x, term.degree);
    },
    evalCompositeTerm: function (x, term) {
      const multiplierValue = this.fx(x, term.multiplier);
      const argumentValue = this.fx(x, term.argument);

      const trigFunc = this.findTrigFunction(term.function);
      if (trigFunc) {
        return Math.pow(
          multiplierValue * trigFunc(argumentValue),
          term.degree
        );
      }

      const expFunc = this.findExpFunction(term.function)
      if (expFunc) {
        const base = term.function === "pow"
          ? expFunc(x, argumentValue)
          : expFunc(argumentValue);

        return Math.pow(multiplierValue * base, term.degree);
      }

      return 0;
    },
    findTrigFunction: function (name) {
      const f = this.builtInFunctions.trigFunctions.find(fn => fn.key === name);
      return f ? f.value : null;
    },
    findExpFunction: function (name) {
      const f = this.builtInFunctions.expFunctions.find(fn => fn.key === name);
      return f ? f.value : null;
    },
    tuple: function (x) {
      return { x: x, y: this.fx(x, this.polynomial.terms) };
    },
    translateX: function (x) {
      const midX = this.xLength / 2;
      return x * this.scaleFactor + midX;
    },
    translateY: function (y) {
      const midY = this.yLength / 2;
      return midY - y * this.scaleFactor;
    },
    plot: function () {
      const ctx = this.$refs.canvas.getContext("2d");
      ctx.lineWidth = 1;

      if (this.polynomial.terms.length > 0) {
        let area = 0;

        for (
          let i = this.polynomial.lowX;
          i <= this.polynomial.highX;
          i += dx
        ) {
          try {
            ctx.strokeStyle = this.color1;
            const p1 = this.tuple(i);
            const p2 = this.tuple(i + dx);

            if (this.calculateAreaUnderSelected) {
              ctx.moveTo(this.translateX(p1.x), this.translateY(p1.y));
              ctx.lineTo(this.translateX(p1.x), this.translateY(0));
              ctx.stroke();
              area += Math.abs(dx * p1.y);
            }

            ctx.moveTo(this.translateX(p1.x), this.translateY(p1.y));
            ctx.lineTo(this.translateX(p2.x), this.translateY(p2.y));
            ctx.stroke();

            if (this.slopeFunctionSelected) {
              const p3 = this.tuple(i + 2 * dx);

              ctx.beginPath();
              ctx.moveTo(
                this.translateX(p1.x),
                this.translateY((p2.y - p1.y) / dx)
              );
              ctx.lineTo(
                this.translateX(p2.x),
                this.translateY((p3.y - p2.y) / dx)
              );

              ctx.strokeStyle = this.color2;
              ctx.stroke();
            }
          } catch (e) {
            console.error(e.msg);
          }
        }
        if (this.calculateAreaUnderSelected)
          this.$emit("receive-area-calculated", area);
      }
    },
  },
  watch: {
    zoom: function (newVal) {
      this.scaleFactor = Math.pow(2, newVal) * zoomFactor;
      this.drawGrid();
      this.plot();
    },
    polynomial: function () {
      console.log("Watcher: polynomial");
      this.plot();
    },
    clearFlag: function (newVal) {
      console.log("Watcher: clearFlag");
      if (newVal) {
        this.drawGrid();
      }
    },
  },
};
</script>
<style scoped>
#myCanvas {
  max-width: 100%;
  height: auto;
  border: 1px solid #d3d3d3;
}
</style>