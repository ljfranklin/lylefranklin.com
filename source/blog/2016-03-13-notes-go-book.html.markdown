
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

## Chapter 4: Composite types

Clear explanation of the relationship between slices and arrays (pg 84).
Not only does a slice abstract away growing the underlying array,
it also allows multiple slices to share the same underlying array.

---

As with many structures in Go, a `nil` slice is equivalent to an empty slice (pg 87).
Good advice to make your zero values useful.

---

I appreciate how easy it is to compare objects for equality in Go (pg 104) as
compared to languages like Java which mixes `==` and `.Equals()` for even simple objects.

---

Another useful JSON tag is '-' which omits the field from serialization (pg 108).
Also, if you're generating a JSON string you'll always want to use tags to remove capitalization.

---

Nicely formatted program output on pg 112.
Good reminder that attention to detail matters :)

## Chapter 5: Functions

One of the features I miss from other languages is default parameters (pg 120).
In a language like Java, method overloading provides a decent workaround.
But in Go, the only workaround I've seen is to "abuse" var-args to allow arguments to be omitted.

---

Nice, succinct explanation of how Go is *pass by value* (pg 120).
Functions always receive a copy of the argument, but if that argument is a
reference type (e.g. pointer, slice, map) the function might modify the contents of that reference.

---

The authors hint at it, but for the sake of readability I usually only use multiple return
values when the second value is an error or a boolean (pg 125).
I've seen code that uses multi-return values as a convenience with other variable types,
and it always feels unexpected.

I also liked the explanation that a boolean as a second return value (typically named *ok*) should be used for methods
that have only one possible failure mode, such as a cast (wrong type) or lookup (key not found) (pg 128).

---

I really don't like named returned values, makes it harder to follow a function's dataflow (pg 127).
I've heard the argument that it makes it more clear *what* the function is returning, but
if it's not clear already, the function is probably poorly named.

---

Nice, concise example showing retries with a timeout and exponential back-off (pg 130).

```
deadline := time.Now().Add(timeout)
for tries := 0; time.Now().Before(deadline); tries++ {
  ...
  time.Sleep(time.Second << uint(tries)) // exponential back-off
}
```

---

I've been bitten by attempting to capture an iteration value in the past (pg 141).
In this example, the variable `dir` represents a storage location for a value, not
the value itself.
Each iteration through the loop reuses the same `dir` variable, so the `os.RemoveAll` call
will attempt to remove only the last assigned value of `dir`.
The fix is to redeclare the iteration variable inside the loop: `dir := dir`.

```
for _, dir := range tempDirs {
  ...
  rmdirs = append(rmdirs), func() {
    os.RemoveAll(dir) // BAD: removes the last dir `len(tempDirs)` times
  })
}
```

---

Big fan of the `defer` keyword (pg 146).
The closeness of "Open()" and "defer Close()" calls allows programmers to visually pattern match.
A missing `defer` "looks wrong", while a missing "Close()" at the end of a long function is easy to forget.

---

The `trace` function is a clever one-liner to print timing info, totally using this (pg 146):

```
defer trace("bigSlowOperation")()
```

```
func trace(msg string) func() {
  start := time.Now()
  log.Printf("enter %s", msg)
  return func() { log.Printf("exit %s (%s)", msg, time.Since(start)) }
}
```

## Chapter 6: Methods

The authors lay out a nice convention: If any method needs a pointer receiver, then all methods on that struct
should have a pointer receiver (pg 158).
Makes it immediately obvious whether you should pass a pointer around vs a value.

---

Nice example of building a set using a bit vector (pg 167), reminds me of a few interviews I've had...

---

Kudos again to the language designers. Capitalize methods to make them public, super simple! (pg 168)

## Chapter 7: Interfaces

> what makes Go's interfaces so distinctive is that they are *satisfied implicitly*. - pg 171

I've found this feature helpful for testing via dependency injection.
If I want to inject a struct from a library that doesn't have a corresponding interface,
I can simply create my own interfaces which that library object implicitly satisfies.

---

The authors give a nice tip for ensuring your concrete class implements a given interface.
Add an assignment from your concrete class to an unused variable that has the desired interface type (pg 177):

```
package bytes

// ensure Buffer satisfies io.Writer
var _ io.Writer = new(bytes.Buffer)

type Buffer struct{
  ...
}
```

---

> A nil interface value, which contains no value at all,
  is not the same as an interface value containing a pointer that happens to be nil - pg 184

I've been bitten by this "subtle trap" as the authors describe it.
Here's the authors' example (pg 185):

```
const debug = true

func main() {
  var buf *bytes.Buffer
  if debug {
    buf = new(bytes.Buffer)
  }
  f(buf)
  if debug {
    ...
  }
}

func f(out io.Writer) {
  if out != nil {
    out.Write([]byte("done!\n")) // possible nil pointer panic
  }
}
```

In Go, interfaces are composed of two parts: the *dynamic type* and the *dynamic value*.
While `out` in this example might have a value of `nil`, its type is `*bytes.Buffer`.
Since at least one of these parts is non-nil, `out != nil` is true.
The fix in this case is to declare `buf` with an interface type (`var buf io.Writer`) so
that the dynamic type is `nil` until an assignment occurs.

---

`tabwriter` is another nice formatting package I'll have to check out (pg 188).
This package prints neatly formatted tables with rows and columns.

---

I feel like the "hello, world" example for most modern programming languages
should now be an HTTP server instead of printing to a terminal (pg 191).
The ease of spinning up a server in Go in so few lines using only standard libs
was what got me excited to initially learn Go.

---

Always use `io.WriteString` to write a string to an `io.Writer`.
Another nice optimization from the authors (pg 209).

---

> Interfaces are only needed when there are two or more concrete types that
  must be dealt with in a uniform way. - pg 216

As I mentioned earlier, I disagree with this statement when dependency injection is involved.
I've found myself creating interfaces that were implemented by a single struct, then
generating a fake implementation from that interface using something like
[counterfeiter](https://github.com/maxbrunsfeld/counterfeiter).

## Chapter 8: Goroutines and channels

The authors give definitions to two styles of concurrent programming:
Communicating Sequential Processes (CSP) and Shared Memory Multithreading (pg 217).
CSP involves passing messages between multiple independent processes, but variables are typically
local to each process. Channels plus goroutines are an example of this style.
Shared memory multithreading involves multiple concurrent threads accessing shared variables.
This style makes use of locks and atomic structures.

---

> when we say *x* happens before *y*, we don't mean merely that *x* occurs earlier in time
than *y*; we mean that it is guaranteed to do so - pg 226

Explanations similar to this first helped me to understand concurrent programming.
"I ran it on my laptop and everything happened in the right order" is not good enough
for parallel programming.

---

My biggest takeaway from this chapter is to be careful to avoid goroutine leaks (pg 233).
These can occur when a function exits, but one or more goroutines are stuck trying to send or
receive on a channel.
These goroutines cannot be garbage collected in this state, a gouroutine leak.

The authors give a couple suggestions to avoid leaks, including
using buffered channels if the know the number of items in advance or using a WaitGroup (pg 237).

---

We hit this exact bug with `time.Tick` leaking goroutines on a past project (pg 246).
The server have very low CPU usage for about three days, then quickly spiked to 100%.
We weren't cleaning up `time.Tick` correctly, and after three days the goroutine leaks
caused the server to crash.
Creating a new timer and explicitly stopping it on exit fixed things up.

---

Another good tip, always call `waitGroup.Add` outside the goroutine that will call `waitGroup.Done` (pg 238).
This ensures that all the `Add` calls are executed before the `waitGroup.Wait` call is executed.

## Chapter 9: Concurrency with shared variables

This chapter provides a well-written explanation of common concurrency gotchas,
how to use mutexes to combat them, and plenty of code examples.
Good chapter to bookmark to check your work at a later date.

---

As with `file.Open` followed by `defer file.Close`, `mutex.Lock` followed by `mutex.Unlock`
provides a nice visual pattern that ensures developers don't forget to release a lock (pg 264).

---

I've seen codebases that explicitly name methods to indicate they are unsafe for concurrent
access, e.g. `depositUnsafe`.
This indicates to that it is the caller's responsibility to acquire any relevant locks.

---

> intuitions about concurrency are not to be trusted! - pg 269

Good reminder to be diligent, ensure all variable access happens in a concurrently safe way.
Attempting to convince yourself that you don't need to bother will probably end in sadness.

---

The `sync.Once` method provides a clean mechanism for a one-time lazy initialization that
is safe for concurrent access (pg 270).

---

`go test -race` is a great low-cost way of detecting race conditions (pg 272).
I make sure to run this flag as part of CI on any Go project.

---

The authors share an example of a non-blocking cache for HTTP requests (pg 277).
The implementation is a bit tricky to get exactly correct, but the authors' do
a fine job of explaining their work.

## TODO

The rest of the chapters...

## Citations

1. Donovan, A. A., & Kernighan, B. W. (2015). The Go programming language. Addison-Wesley.
