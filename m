From: Jason Dixon <jason-a0y0GdpcbPLlcHVOVdbKLw@public.gmane.org>
Subject: Re: That whole "Linux stealing our code" thing
Date: Sat, 1 Sep 2007 20:36:24 -0400
Message-ID: <3A831845-B630-42AD-B52F-DC9EA2060BAE@dixongroup.net>
References: <200709010140.l811eq9H005896@cvs.openbsd.org> <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com> <46D99FB7.6030505@garzik.org> <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com> <20070901205457.GK9260@stusta.de> <f34ca13c0709011427u <20070901215225.GM9260@stusta.de>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mureninc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
To: bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070901215225.GM9260-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sep 1, 2007, at 5:52 PM, Adrian Bunk wrote:

> OK, I begin to understand this, there seem to be three different types
> of files changed by Jiri's patch:
> 1. dual licenced files planned to make GPL-only
> 2. previously dual licenced files with a too recent version used  
> planned
>    to make GPL-only
> 3. never dual licenced files planned to make GPL-only
>
> For files under 1. and 2. Reyk did contribute to dual licenced code
> without touching the licence, but I missed that there's also code  
> unter 3.
>
> So there is a problem, but not with the code under 1. (unless you plan
> to change the semantics of the word "alternatively"), the problem is
> with some headers under 2. plus the code under 3.

The BSD license plainly states:

"Permission to use, copy, modify, and/or distribute this software for  
any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies."

Once the grantor (Reyk) releases his code under that license, it must  
remain.  You are free to derive work and redistribute under your  
license, but the original copyright and license permission remains  
intact.  Many other entities (Microsoft, Apple, Sun, etc) have used  
BSD code and have no problem understanding this.  Why is this so  
difficult for the Linux brain share to absorb?

As a former Linux advocate and current OpenBSD user/developer, I'm  
appalled that fellow open-source developers would see fit to  
cavalierly disregard the rights of the original copyright holder.   
You wield the GPL when it suits you, and trample the courtesies of  
non-GPL developers just because you [think you] can.  As bad as  
Jiri's offense was, it pales to the impudence displayed by Alan Cox,  
one of the so-called defenders of free software.

Shame on you all.

---
Jason Dixon
DixonGroup Consulting
http://www.dixongroup.net
