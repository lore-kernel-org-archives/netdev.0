From: "Ihar 'Philips' Filipau" <filia@softhome.net>
Subject: Re: TOE brain dump
Date: Mon, 04 Aug 2003 20:48:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2EAA78.60202@softhome.net>
References: <1060015518.1103.399.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1060015518.1103.399.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> to nit: Its no longer about routing or bridging, friend. Thats like getting 
> fries at mcdonalds.
> 

   1GE/10GE - for $5?
   I'm first in the shoping queue!!!-)))

   Since I see no reasonable out-come of this discussion I left it.

   TOE as I see - since my company utilizes several of them - are too 
different and too specialized to application/protocols. And yes - price 
of development/deployment maters too. Linux support for those protocols 
is inmature. It cannot handle or requirements even software-wise. I'm 
not talking about timing requirements - linux network in general is not 
(even soft) real-time.

   My personal flame-meter is out of scale ;-)
   I shall join the discussion back when I will see any real ideas.


 > If all you wanted was to do L3 - why not just buy a $5 chip that
 > can do this for a lot more interfaces? Why sweat over
 > optimizing L3 routing in a 3K space?

   We are doing not a teapot, and high level spec for this code takes 
around 15 pages.
   3k - it is not optimized - we have limit around 2GB ;-)
   It just takes only 3k. And it handles some special (read - 
proprietary) functions too - some bugs of some other pieces of hardware. 
NPU does all stuff by itself, but sometimes we need to extract 
configuration information which is direct to us, for example.
