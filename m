From: jamal <hadi@cyberus.ca>
Subject: Re: TOE brain dump
Date: 04 Aug 2003 15:42:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060026149.1102.411.camel@jzny.localdomain>
References: <1060015518.1103.399.camel@jzny.localdomain>
	 <3F2EAA78.60202@softhome.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ihar 'Philips' Filipau" <filia@softhome.net>
In-Reply-To: <3F2EAA78.60202@softhome.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-08-04 at 14:48, Ihar 'Philips' Filipau wrote:
> jamal wrote:
> > to nit: Its no longer about routing or bridging, friend. Thats like getting 
> > fries at mcdonalds.
> > 
> 
>    1GE/10GE - for $5?
>    I'm first in the shoping queue!!!-)))
> 

I thought you were talking about a 2 Gige interface doing routing, no?
Do the math: Dell will happily sell you a (managed?) switch which has
8Giges on it for about $300. It does wire rate on all 8 interfaces. All
ready to go in a 1U form factor. How much do you think that chip costs?
Lets say it doesnt do L3, how much more do you think it will cost to do
L3 in quantities?

>    Since I see no reasonable out-come of this discussion I left it.
> 
>    TOE as I see - since my company utilizes several of them - are too 
> different and too specialized to application/protocols. And yes - price 
> of development/deployment maters too. Linux support for those protocols 
> is inmature. It cannot handle or requirements even software-wise. I'm 
> not talking about timing requirements - linux network in general is not 
> (even soft) real-time.
> 

Now this is anti-social talk;-> Why do you need to have realtime for any
of this stuff? 

>    My personal flame-meter is out of scale ;-)
>    I shall join the discussion back when I will see any real ideas.
> 

Please dont dissapear, a lot of questions need answers;->

> 
>  > If all you wanted was to do L3 - why not just buy a $5 chip that
>  > can do this for a lot more interfaces? Why sweat over
>  > optimizing L3 routing in a 3K space?
> 
>    We are doing not a teapot, and high level spec for this code takes 
> around 15 pages.
>    3k - it is not optimized - we have limit around 2GB ;-)

I am really confused now. We must be talking about different class of
devices. NPUs as i know them are very limited in how much code you can
stash them. In the 10K ranges is already overkill.
Do you have any URL i can look at on what you are describing?

>    It just takes only 3k. And it handles some special (read - 
> proprietary) functions too - some bugs of some other pieces of hardware. 
> NPU does all stuff by itself, but sometimes we need to extract 
> configuration information which is direct to us, for example.

Please provide me a pointer if you can - I am very interested in the 2G
code space you mention.

cheers,
jamal

> 
