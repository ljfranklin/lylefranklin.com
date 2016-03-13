---
published: false
---

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

## Citations

1. Donovan, A. A., & Kernighan, B. W. (2015). The Go programming language. Addison-Wesley.
