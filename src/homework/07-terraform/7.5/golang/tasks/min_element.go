package tasks

import "fmt"

func MinElement() {
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}

	fmt.Printf("Min element is %d\n", minElem(x))
}

func minElem(list []int) int {
	min := list[0]

	for i := 1; i < len(list); i++ {
		current := list[i]

		if current < min {
			min = current
		}
	}

	return min
}
