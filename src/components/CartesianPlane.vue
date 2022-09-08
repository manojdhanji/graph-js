<template>
  <canvas
    id="myCanvas"
    :width="xLength"
    :height="yLength"
    ref="canvas"
  ></canvas>
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
      let y = 0.0;
      for (const t of terms) {
        if (t.type === "Simple") {
          y += t.coefficient * Math.pow(x, t.degree);
        } else {
          const trigBuiltInFunc = this.builtInFunctions.trigFunctions.find(
            (f) => f.key === t.function
          );
          if (trigBuiltInFunc) {
            y +=
              this.fx(x, t.multiplier) *
              trigBuiltInFunc.value(this.fx(x, t.argument));
          }
          const expBuiltInFunc = this.builtInFunctions.expFunctions.find(
            (f) => f.key === t.function
          );
          if (expBuiltInFunc) {
            y +=
              this.fx(x, t.multiplier) *
              expBuiltInFunc.value(this.fx(x, t.argument));
          }
          y = Math.pow(y, t.degree);
        }
      }
      if (isNaN(y) || !isFinite(y)) throw { msg: "NaN" };
      //console.log("x, y: ", x, y);
      return y;
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
      //const midX = this.xLength / 2;
      //const midY = this.yLength / 2;
      const ctx = this.$refs.canvas.getContext("2d");

      ctx.lineWidth = 1;
      //console.dir(this.polynomial);
      if (this.polynomial.terms.length > 0) {
        let area = 0.0;

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
            //console.error(e.msg);
          }
        }
        //console.log("area: " + area);
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
#canvas {
  border: 1px solid #d3d3d3;
}
</style>