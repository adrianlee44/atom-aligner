testing = "123"
test = "321"

someFn test

test =
  foo: bar
  helloworld: test
  star: war

longPrefix = "test"
prefix += "hello"

noSpace="work"

moreComplex =
  hello: {not: "world"}
  testing: "123"

multipleOnSameLine = [
  ["hello", 2112, 12939, "testing"]
  ["abc", 19293, 102304, "more"]
]

    test = "123"
    testing = "abc"

colorMapping =
  # block 1
  red: '#FF0000'
  white: '#FFFFFF'
  black: '#000000'
  # block 2
  blue: '#0000FF'
  green: '#00FF00'
  purple: '#FF00E1'
  #block 3
  gray: '#A8A8A8'
  yellow: '#F6FF00'
  orange: '#FFAE00'

trailingComments =
  comment1: 'something' # first comment
  comment2: 'hi' # second comment
  # this is a comment only line
  comment3: 'world' # third comment
