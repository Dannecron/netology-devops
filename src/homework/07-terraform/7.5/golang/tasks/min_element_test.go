package tasks

import (
	"testing"
)

func MinElemTest(t *testing.T) {
	list := []int{1, 2, 3, 4}
	expectedResult := 1
	actualResult := minElem(list)

	if expectedResult != actualResult {
		t.Fatalf("minElem result is %d, expected %d", actualResult, expectedResult)
	}
}
