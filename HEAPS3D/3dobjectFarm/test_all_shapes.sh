#!/bin/bash

# Test all 39 shapes to verify they render correctly
# Usage: ./test_all_shapes.sh

shapes=(
  # Primitives (9)
  "Box" "Capsule" "Cone" "Cylinder" "Ellipsoid" "Plane" "Pyramid" "Sphere" "Torus"
  # 2D Primitives (5)
  "Box2D" "Circle" "Heart" "RoundedBox2D" "Star"
  # Derivates (6)
  "HalfCapsule" "HoledPlane" "HollowBox" "HollowSphere" "QuarterTorus" "ShellCylinder"
  # 2D Organics (7)
  "FlowerPetalRing" "LeafPair" "LeafSpiral" "LotusFringe" "OrnateKnot" "SpiralVine" "VineCurl"
  # 3D Organic (12)
  "BlobbyCluster" "BubbleCrown" "BulbTreeCrown" "DripCone" "JellyDonut" "KnotTube" "MeltedBox" "PuffyCross" "RibbonTwist" "SoftSphereWrap" "UndulatingPlane" "WavyCapsule"
)

failed_shapes=()
total=${#shapes[@]}
passed=0

echo "Testing all $total shapes..."
echo "======================================"

for shape in "${shapes[@]}"; do
  echo -n "Testing $shape... "

  # Convert to lowercase for flag
  shape_lower=$(echo "$shape" | tr '[:upper:]' '[:lower:]')

  # Run with --sc flag and shape name (1 second timeout)
  timeout 1 hl bin/main.hl --sc --${shape_lower} > /dev/null 2>&1
  exit_code=$?

  # Exit code 124 = timeout (expected, means it ran successfully for 1 second)
  # Exit code 0 = exited normally (also OK if screenshot was taken)
  if [ $exit_code -eq 124 ] || [ $exit_code -eq 0 ]; then
    echo "✓ PASS"
    ((passed++))
  else
    echo "✗ FAIL (exit code: $exit_code)"
    failed_shapes+=("$shape")
  fi
done

echo "======================================"
echo "Results: $passed/$total passed"

if [ ${#failed_shapes[@]} -eq 0 ]; then
  echo "All shapes tested successfully!"
  exit 0
else
  echo "Failed shapes:"
  printf '  - %s\n' "${failed_shapes[@]}"
  exit 1
fi
