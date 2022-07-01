package main

import (
	"fmt"

	"main/tasks"
)

func main() {
	var taskNum int
	fmt.Println("Enter number of task")
	fmt.Scan(&taskNum)

	switch taskNum {
	case 1:
		tasks.MetersToFeet()
		break
	case 2:
		tasks.MinElement()
		break
	case 3:
		tasks.DivThree()
		break
	default:
		fmt.Println("Unknown task")
		break
	}
}
