From: Igor Sobrado <igor-wnk7FUYfzmtu2DZcH3qp6zJQgOOX0AMFMQBsIrBqeMw@public.gmane.org>
Subject: Re: Fwd: That whole "Linux stealing our code" thing
Date: Sun, 02 Sep 2007 14:28:28 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709021416130.6181@condmat1.ciencias.uniovi.es>
References: <200709010140.l811eq9H005896@cvs.openbsd.org>
 <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com>
 <46D99FB7.6030505@garzik.org>
 <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com>
 <20070901205457.GK9260@stusta.de> <20070902113638.78fbd202@the-village.bc.nu>
 <Pine.LNX.4.64.0709021303001.4312@condmat1.ciencias.uniovi.es>
 <20070902115041.GM16016@stusta.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"Constantine A. Murenin" <mureninc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <20070902115041.GM16016-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2 Sep 2007, Adrian Bunk wrote:
> On Sun, Sep 02, 2007 at 01:20:27PM +0200, Igor Sobrado wrote:
>> Reyk code was never dual licensed!  His code is under truly free licensing
>> terms (BSD).
>
> Jiri's patch touched both files containing BSD-only code by Reyk and
> code Reyk contributed to leaving the file dual licenced.

Ok.

> You mixed two completely different things in your email:
>
> 1. Jiri's patch (that was never merged into Linux) not only removed the
>   BSD header from dual licenced files but also from not dual licenced
>   files.
>
> 2. Theo accused Alan that telling people that it was OK to choose one
>   licence for dual licenced code was "advising people to break the law".
>
> Jiri's patch was legally not OK regarding 1. - there's no discussion
> regarding this.
>
> The point 2 is what the email of Theo that was forwarded to linux-kernel
> is about and what the discussion is about. That's quite a rude action
> by Theo unless he's able to prove that this accusation is correct.

When code is multi-licensed it must be distributed under *all* these 
licensing terms concurrently.  It is easy to understand.  Removing (or 
changing) the conditions that apply to the program from the source code 
and documentation *without* an authorization from all the author(s) is 
illegal.

So, a multi-licensed file remains multi-licensed except when all authors 
agree about a change in the licensing terms.  And it is clear on the BSD 
license that a modification of the distribution terms is illegal.  It is 
the first clause on the BSD license:

  * 1. Redistributions of source code must retain the above copyright
  *    notice, this list of conditions and the following disclaimer,
  *    without modification.

So, removing (or changing) the list of conditions on the BSD license is 
not allowed.

Igor.
