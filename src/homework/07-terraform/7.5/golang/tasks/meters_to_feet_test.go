package tasks

import (
	"testing"
)

func TestConvert(t *testing.T) {
	meters := 3048
	var expectedResult float32 = 10000.0

	result := convert(meters)

	if result != expectedResult {
		t.Fatalf("convert result is %f, expected %f", result, expectedResult)
	}
}
