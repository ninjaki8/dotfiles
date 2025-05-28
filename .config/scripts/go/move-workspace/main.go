package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"sort"
	"strconv"
)

var excludedIDs = map[int]bool{11: true}
var targetMonitor = "DP-1" // Change this to the name of your main monitor

type Workspace struct {
	ID      int    `json:"id"`
	Monitor string `json:"monitor"`
}

func getCurrentWorkspaceID() (int, error) {
	cmd := exec.Command("hyprctl", "activeworkspace", "-j")
	output, err := cmd.Output()
	if err != nil {
		return 0, fmt.Errorf("failed to run hyprctl: %w", err)
	}

	var ws Workspace
	if err := json.Unmarshal(output, &ws); err != nil {
		return 0, fmt.Errorf("failed to parse JSON: %w", err)
	}

	return ws.ID, nil
}

func getValidWorkspaceIDs() ([]int, error) {
	cmd := exec.Command("hyprctl", "workspaces", "-j")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to get workspaces: %w", err)
	}

	var workspaces []Workspace
	if err := json.Unmarshal(output, &workspaces); err != nil {
		return nil, fmt.Errorf("failed to parse workspaces JSON: %w", err)
	}

	var ids []int
	for _, ws := range workspaces {
		if ws.Monitor == targetMonitor && !excludedIDs[ws.ID] {
			ids = append(ids, ws.ID)
		}
	}

	sort.Ints(ids)
	return ids, nil
}

func dispatchWorkspace(id int) error {
	cmd := exec.Command("hyprctl", "dispatch", "workspace", strconv.Itoa(id))
	return cmd.Run()
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: move_workspace <next|prev>")
		os.Exit(1)
	}

	direction := os.Args[1]
	currentID, err := getCurrentWorkspaceID()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	validIDs, err := getValidWorkspaceIDs()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	switch direction {
	case "next":
		for _, id := range validIDs {
			if id > currentID {
				dispatchWorkspace(id)
				return
			}
		}
	case "prev":
		for i := len(validIDs) - 1; i >= 0; i-- {
			id := validIDs[i]
			if id < currentID {
				dispatchWorkspace(id)
				return
			}
		}
	default:
		fmt.Println("Invalid direction. Use 'next' or 'prev'.")
		os.Exit(1)
	}
}

