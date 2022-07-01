package tasks

import "fmt"

const metersInFeet float32 = 0.3048

func MetersToFeet() {
	var meters int

	fmt.Println("Please, input value in meters:")
	fmt.Scan(&meters)
	fmt.Printf("%f", convert(meters))
}

func convert(meters int) float32 {
	return float32(meters) / metersInFeet
}
