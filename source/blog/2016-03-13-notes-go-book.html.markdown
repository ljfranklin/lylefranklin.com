
# Notes from The Go Programming Language

I've been writing Go for the past year while working on the
[Cloud Foundry](https://www.cloudfoundry.org/) platform.
To get started using the language, I ran through a few of the resources on the
Golang homepage such as [A Tour of Go](https://tour.golang.org) and [Effective Go](https://golang.org/doc/effective_go.html).
I also read through the excellent [Go by Example](https://gobyexample.com/) site which shows annotated example programs.
The fact that you can be fairly proficient in the language after an afternoon of reading shows how simple and well-designed the language is.

I picked up [The Go Programming Language](http://www.gopl.io/) to get a better understanding of the finer points of the language.
This post is compiled from my notes as I read through this book.
Pull quotes are taken from the text, see citation 1.

## Chapter 1: Tutorial

> When you're learning a new language, there's a natural tendency to write code as you would have written it in a language you already know. - pg 1

I was definitely guilty of this when I was first learning Go.
On the plus side, a combination of limited language features and opinionated tools (e.g. go fmt) helps to quickly build a sense of what is "idiomatic" in Go.

---

I liked the examples chosen in the first chapter, such as recreating the `uniq` unix utility in Go (pg 11).
It's a toy example that's actually useful and feels like a "real" program (reads from stdin or passed file name as arguments).
The examples are also rooted in systems programming which is one of Go's strongest areas.

---

Another example created an animated GIF by overlaying sine waves (pg 13).
I haven't had a chance to use the `image` packages in Go, so it was neat to see it in action.
That said, the Ubuntu image viewer threw an error when I tried to open the GIF.
There's an open [issue](https://github.com/golang/go/issues/13746) indicating it might be fixed in Golang 1.7.
Oh well, the GIF displays without issue in Chrome or Firefox.

---

I had not seen the [ioutil.Discard](https://golang.org/pkg/io/ioutil/#pkg-variables) utility before (pg 18), basically a writer to `/dev/null`.
Would be useful when writing tests rather than initializing an empty Buffer.

---

Exercise 1.11 (pg 19) asks the reader to consider what would happen if a site fails to respond when `http.Get` is called.
I've been bitten by this before, the default HTTP client does not have a timeout configured meaning the call will block forever.
This is almost certainly not what you want in your production code.
Always construct your own `http.Client` with a reasonable timeout in your production code.

---

One of the things that got me excited to learn Go was its "Hello world" web server example (pg 19-20).
Being able to spin up a functional web server in a few lines of code with only standard libs starts things off on the right foot.

---

The first chapter sprints through examples ranging from "Hello world", image generation, and concurrently fetching URLs in 20 pages.
The target audience for this book seems to be at least intermediate developers that have experience from other similar languages to draw from.
While this makes it a quick read for more experienced developers, beginner students might have trouble with the pacing.

## Chapter 2: Program Structure

I like the authors' style tip to type acronyms in the same case, preferring `escapeHTML` over `escapeHtml` (pg 28).
I've used both styles in the past, but capitalizing acronyms more closely matches how they're typed outside of code.

---

> in Go there is no such thing as an uninitialized variable - pg 30

I appreciate the consistent experience this provides.
For example incrementing a map value can be written as:

```
someMap[key]++
```

instead of:

```
if someMap[key] == nil {
  someMap[key] = 0
}
someMap[key]++
```

---

When I initially read the paragraph describing short variable declarations (pg 30), I was disappointed the authors didn't mention the danger of accidentally shadowing variables.
For example, the following declares a new local variable `someFile` that shadows the package level variable of the same name, an easy mistake to make:

```
var someFile string

func processFile() {
  someFile, err := os.Open("/path/to/file")
  ...
}
```

Instead you can declare `err` separately and use normal assignment to avoid shadowing:

```
var someFile string

func processFile() {
  var err error
  someFile, err = os.Open("/path/to/file")
  ...
}
```

However, the authors loop back to point common mistake later in the chapter (pg 49).
Nice catch!

---

I like the idea of Go's type aliases to make the code more readable and type safe.
The authors use temperature types as an example (pg 39):

```
type Celsius float64
type Fahrenheit float64
```

So far I've not used this feature much in my own code, definitely something to do more often.

---

> It is an error to import a package and then not refer to it - pg 43

I love the design philosophy that code with objectively poor style should be a compiler error rather than a warning.
Little features like this help keep the code tidy without reliance on linters and vetters (not to say that `golint` and `go vet` aren't still useful).

---

I was surprised to find out about the `init()` function (pg 44) as I haven't seen it used in the code bases I've seen.
You can specify any number of `func init() {...}` methods in a package and they will be run automatically when the program starts.
[Effective Go](https://golang.org/doc/effective_go.html#init) mentions that it can be useful for verifying pre-conditions like whether an environment variable is set.

## Chapter 3: Basic Data types

This chapter gave several examples of more advanced usage of the `fmt` package.
These include using `fmt.Printf("%08b\n", x)` to print a `uint8` with padding zeros up to a length of 8 (pg 54) and
printing a right-aligned set of numbers with `fmt.Printf("x = %8.3f\n", x)` to print an 8 character field with 3 digits of precision (pg 57).
The next CLI I work on is getting some additional pretty printing.

---

The authors offered a lovely explanation for a question I never thought to ask:
why do functions that always return a non-negative result like `len()` usually return an `int` instead of `uint`?
Their example demonstrates a subtle overflow error that could be encountered when dealing with a `uint` (pg 54):

```
medals := []string{"gold", "silver", "bronze"}
for i := len(medals) - 1; i >= 0; i-- {
  fmt.Println(medals[i])
}
```

In this example, on the fourth iteration `i` would jump from zero to the max `uint` value resulting in an index out of bounds error.
The authors described this error as "calamitous", which is a word I'd like to work into an email sometime soon.

---

The authors included two wonderful math based examples to illustrate the type system:
generating a 3D sine wave mesh in SVG (pg 58) and an image of the Mandelbrot set (pg 62).
Makes me want to brush up on my math skills a bit.
Also shout out to this [Numberphile video](https://www.youtube.com/watch?v=NGMRB4O922I) for teaching me what a Mandelbrot set is.

---

Ironically my favorite part of this chapter was only tangentially related to Go.
The authors include a concise and informative explanation of the relationship between
ASCII, Unicode, and UTF-8 (pg 67).
I've not yet worked on a project that had non-ASCII character encoding as a requirement,
definitely something I need to read up on.

For example, I would have thought that `len(someString)` was an okay thing to do, not so when Unicode is involved.
Calling `len(someUTFString)` will give you the length of the string in bytes, but some characters may take up more that one byte.
Instead you can call `utf8.RunCountInString(s)` or use `range` which automatically does the UTF-8 conversion (pg 69, 70).

---

Small nitpick, but I wouldn't expect a `basename` function to remove the file extension (pg 72).
That is all, carry on.

---

I'm glad I read the section on using `iota` to generate enums (pg 77).
This keyword had alway felt a little magic to me, so it's nice to understand how to works and
how it can be extended to more complex implementations like generating powers of 1024 (pg 78).


## TODO

The rest of the chapters...

## Citations

1. Donovan, A. A., & Kernighan, B. W. (2015). The Go programming language. Addison-Wesley.
