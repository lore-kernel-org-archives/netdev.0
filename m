From: Igor Sobrado <igor-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sun, 02 Sep 2007 15:00:46 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709021446550.6181@condmat1.ciencias.uniovi.es>
References: <200709010140.l811eq9H005896@cvs.openbsd.org>
 <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com>
 <46D99FB7.6030505@garzik.org>
 <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com>
 <20070901205457.GK9260@stusta.de> <20070902113638.78fbd202@the-village.bc.nu>
 <Pine.LNX.4.64.0709021303001.4312@condmat1.ciencias.uniovi.es>
 <20070902115041.GM16016@stusta.de>
 <Pine.LNX.4.64.0709021416130.6181@condmat1.ciencias.uniovi.es>
 <20070902134612.28a88761@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Constantine A. Murenin" <mureninc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <20070902134612.28a88761-v58gJUvfdfWUJIigds3554dd74u8MsAO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2 Sep 2007, Alan Cox wrote:

>> So, a multi-licensed file remains multi-licensed except when all authors
>> agree about a change in the licensing terms.  And it is clear on the BSD
>
> Not strictly true. They can either agree to a change and issue one or
> they can convey to other parties the right to change the terms. The GPL
> for example does this for version selection.

So, under a dual-licensed BSD/GPL code the latter license allows a 
developer to remove the GPL license itself and release a single-licensed 
BSD code if other parties want to do it?

> A multi-licensed work (note work not file - don't assume a file is a
> boundary of a work) which conveys the choice of licence (as some bits of
> ath5k did) allows a receiving party to choose the licence it wishes.
> Failing that OpenBSD would have turned itself GPL by adding that file as
> according to your argument "it must be distributed under *all* these
> licensing terms concurrently".

I would assume a file as a boundary of a work in the case that file is 
under different licensing terms to the rest of the software package.  On a 
lot of software packages different modules are covered under different 
licensing terms.

We can choose what license terms we will honor; however, we do not have 
the ability to remove the licensing terms we do not like.

Igor.
