# RANKING.md — Best → Worst with 1–2 line rationales

**Task:** Implement `move_towards` with signature `(x, y, tx, ty, speed, dt)` returning `(nx, ny, reached)`.

- **A (Best):** Correct guard, pure function (no globals), returns `reached`, constant-time math.  
- **B (Okay):** Mutates input, implicit `0/0` risk at target, no `reached` flag.  
- **C (Worst):** Ignores `dt/speed`, uses globals, frame-dependent; incorrect by spec.
