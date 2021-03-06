package main

import (
	"fmt"
	"log"

	"github.com/shirou/gopsutil/host"
	"github.com/shirou/gopsutil/mem"
)

func main() {
	fmt.Println("Starting getting memory info...")
	mem, err := mem.VirtualMemory()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Total: %v, Free:%v, UsedPercent:%f%%\n", mem.Total, mem.Free, mem.UsedPercent)
	fmt.Println(mem)

	fmt.Println("Starting getting host info...")
	info, err := host.Info()
	if err != nil {
		log.Fatalf("error %v", err)
	}
	empty := &host.InfoStat{}
	if info == empty {
		fmt.Printf("Could not get hostinfo %v", info)
	}
	if info.Procs == 0 {
		fmt.Println("Could not determine the number of host processes")
	}

	facts := make(map[string]interface{})
	facts["os"] = info.OS
	facts["platform"] = info.Platform
	facts["platform_family"] = info.PlatformFamily
	facts["platform_version"] = info.PlatformVersion
	facts["fqdn"] = nil
	facts["domain"] = nil
	facts["hostname"] = info.Hostname

	fmt.Printf("%+v\n", facts)
}
