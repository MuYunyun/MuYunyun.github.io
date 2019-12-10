---
title: INHERITED AND NON-INHERITED IN CSS
copyright: true
tags:
  - CSS
categories:
  - CSS
abbrlink: 33fba87f
date: 2019-12-10 09:30:15
---

![](http://with.muyunyun.cn/b22bcdb94d354d3f301cae7997d9cd17.jpg)

When I look up css properties in MDN's specifications section, there are some properties in it and it seems unfamiliar to me. So I try to find out some of them today.

<!--more-->

The follow list try to give one word to specify the meaning of them.

* Initial value: Specify the CSS property's default value;
* Applies to: Specify which elements to apply to;
* Inherited: Specify the CSS property is inherited or non-inherited;
* [Media](https://www.w3.org/TR/css3-mediaqueries/): Specify how a document is to be presented on different media;
* [Computed value](https://developer.mozilla.org/en-US/docs/Web/CSS/computed_value): The CSS property that is transferred from parent to child;
* [Animation type](https://drafts.csswg.org/web-animations/#animation-type)
* [Canonical order](https://developer.mozilla.org/en-US/docs/Glossary/Canonical_order): Some CSS properties(font、background...) have their own CSS property value order.

And this article is to discuss the topic about the knowledge of inherited and non-inherited.

### Initial value between inherited and non-inherited

The initial value of a CSS property is its default value.

The Initial value has two different behavior between `inherited properties` and `non-inherited properties`.

For `inherited properties`, the initial value is `used on the root element only`.

```html
<span style="color: red">
  hello, <em>CSS</em>
</span>
```

The result is the color of both `span` and `em` element are red. Because the color is an inherited property, the element will get the color property from the parent recursively until to document.

For `non-inherited properties`, the initial value is `used on every element`. When no value for a non-inherited property has been specified on an element, the element gets the initial value directly.

```html
<span style="border: 1px solid black">
  hello, <em>CSS</em>
</span>
```

The result is the border is only effected on `span` element, not `em`. Because the border is a non-inherited property, and there is no border property specified on the em, so the em get the border's initial value `none`.

It mentioned much times about inherited value and non-inherited value above, and now we sort out css properties.

### Inherited Type

I've collected some inherited types in css, they are listed as follow:

* `Font Type`: font-style、font-variant、font-weight、font-stretch、font-size、font-family、color、line-height;
* `Space Type`: letter-spacing、word-spacing、white-space;
* `Letter Type`: text-align、text-indent、text-shadow、text-transform;
* `List Type`: list-style、list-style-type、list-style-position;
* `Others`: visibility、cursor;

### Non-Inherited Type

In the opposite of inherited type, the non-inherited types are listed as follow:

* `Layout Type`: float、position、left、right、top、bottom、z-index、display
* `Box Type`: width、max-width、min-width、height、max-height、min-height、margin、padding、border;
* `Background Type`: background-size、background-image、background-clip、background-color、background-origin、background-position、background-repeat;
* `Others`: overflow、text-overflow、vertical-align;

### Recap

These section introduces the inherited concept in CSS, and distinguish some inherited type and some non-inherited type from css properties. Hope it's helpful for you.