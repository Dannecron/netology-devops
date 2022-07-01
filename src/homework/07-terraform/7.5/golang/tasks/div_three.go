package tasks

import "fmt"

func DivThree() {
	fmt.Println("Numbers that are divisible by 3:")
	for i := 1; i <= 100; i++ {
		if i%3 == 0 {
			fmt.Printf("%d, ", i)
		}
	}
}
