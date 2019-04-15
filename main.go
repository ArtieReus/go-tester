package main

import (
	"fmt"

	"github.com/shirou/gopsutil/host"
	"github.com/shirou/gopsutil/mem"
	// "github.com/shirou/gopsutil/host"
	// "github.com/shirou/gopsutil/mem"
)

func main() {
	mem, _ := mem.VirtualMemory()
	fmt.Printf("Total: %v, Free:%v, UsedPercent:%f%%\n", mem.Total, mem.Free, mem.UsedPercent)
	fmt.Println(mem)

	info, err := host.Info()
	if err != nil {
		fmt.Printf("error %v", err)
	}
	empty := &host.InfoStat{}
	if info == empty {
		fmt.Printf("Could not get hostinfo %v", info)
	}
	if info.Procs == 0 {
		fmt.Println("Could not determine the number of host processes")
	}
	fmt.Printf("%+v\n", info)
}
