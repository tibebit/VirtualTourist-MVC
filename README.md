# VirtualTourist-MVC
The application allows users to customize a map with their annotations. Each annotation is like a tour stop and holds a collection of photos downloaded from [Flickr](https://www.flickr.com).

## Structure Overview
These are the app's main screens:
* **Travel Location VC**: shows a map that can be annotated with pins. When users tap on a pin, the app shows the Photo Album VC
* **Photo Album VC**: shows a collection of photos associated with a specific annotation

## Screens Details
### Photo Album VC
It's made up of the following components:
* a map showing the pin selected
* a collection of photos for that pin. They can be retrieved from two sources:
  * the Flickr API
  * Core Data
* a button to refresh the photos collection

## Requirements
To build and run the app, you'll need the following:
* iOS 13
* Xcode 11

## License
MIT License

Copyright (c) 2022 Fabio Tiberio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
