// PNG -> Arma .paa (DXT5). Thin wrapper around github.com/woozymasta/paa,
// the same encoder this repo's existing role.paa/rolebg.paa/roleshadow.paa
// were produced with - a subtly wrong hand-rolled PAA just trades one silent
// texture-load failure for another.
package main

import (
	"fmt"
	"image"
	"os"

	"github.com/woozymasta/paa"
	_ "image/png"
)

func main() {
	if len(os.Args) != 3 {
		fmt.Fprintln(os.Stderr, "usage: png2paa in.png out.paa")
		os.Exit(2)
	}
	in, err := os.Open(os.Args[1])
	if err != nil { panic(err) }
	defer in.Close()
	img, _, err := image.Decode(in)
	if err != nil { panic(err) }
	out, err := os.Create(os.Args[2])
	if err != nil { panic(err) }
	defer out.Close()
	if err := paa.Encode(out, img); err != nil { panic(err) }
	b := img.Bounds()
	fmt.Printf("%s -> %s (%dx%d)\n", os.Args[1], os.Args[2], b.Dx(), b.Dy())
}
