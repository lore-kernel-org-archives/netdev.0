From: Jonathan Gray <jsg-NVmhupfugZeeZLLa646FqQ@public.gmane.org>
Subject: Re: That whole "Linux stealing our code" thing
Date: Sun, 2 Sep 2007 12:22:53 +1000
Message-ID: <20070902022253.GA18201@mail.netspace.net.au>
References: <200709010140.l811eq9H005896@cvs.openbsd.org> <f34ca13c0709010948v67b04b58lb098713dc38c4d6a@mail.gmail.com> <46D99FB7.6030505@garzik.org> <f34ca13c0709011037p221cb40fjf69651d1858df212@mail.gmail.com> <20070901205457.GK9260@stusta.de> <3A831845-B630-42AD-B52F-DC9EA2060BAE@dixongroup.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mureninc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
To: Jason Dixon <jason-a0y0GdpcbPLlcHVOVdbKLw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3A831845-B630-42AD-B52F-DC9EA2060BAE-a0y0GdpcbPLlcHVOVdbKLw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 01, 2007 at 08:36:24PM -0400, Jason Dixon wrote:
>
> On Sep 1, 2007, at 5:52 PM, Adrian Bunk wrote:
>
>> OK, I begin to understand this, there seem to be three different types
>> of files changed by Jiri's patch:
>> 1. dual licenced files planned to make GPL-only
>> 2. previously dual licenced files with a too recent version used planned
>>    to make GPL-only
>> 3. never dual licenced files planned to make GPL-only
>>
>> For files under 1. and 2. Reyk did contribute to dual licenced code
>> without touching the licence, but I missed that there's also code unter 3.
>>
>> So there is a problem, but not with the code under 1. (unless you plan
>> to change the semantics of the word "alternatively"), the problem is
>> with some headers under 2. plus the code under 3.
>
> The BSD license plainly states:
>
> "Permission to use, copy, modify, and/or distribute this software for any
> purpose with or without fee is hereby granted, provided that the above
> copyright notice and this permission notice appear in all copies."
>
> Once the grantor (Reyk) releases his code under that license, it must 
> remain.  You are free to derive work and redistribute under your license, 
> but the original copyright and license permission remains intact.  Many 
> other entities (Microsoft, Apple, Sun, etc) have used BSD code and have no 
> problem understanding this.  Why is this so difficult for the Linux brain 
> share to absorb?
>
> As a former Linux advocate and current OpenBSD user/developer, I'm appalled 
> that fellow open-source developers would see fit to cavalierly disregard 
> the rights of the original copyright holder.  You wield the GPL when it 
> suits you, and trample the courtesies of non-GPL developers just because 
> you [think you] can.  As bad as Jiri's offense was, it pales to the 
> impudence displayed by Alan Cox, one of the so-called defenders of free 
> software.

>From http://www.mac.linux-m68k.org/docs/macpaper.php

"Always be the second operating system port to an undocumented platform.
The sterling work done by the OpenBSD/Mac team was a huge help to the
Linux project. I'm also happy to say that while half of the world may
sit on usenet advocacy groups throwing manure the relationship between
the Linux and BSD Macintosh teams has always been one of mutual
co-operation. Together we advance our detective work and knowledge of
the Macintosh platforms to the good of all Macintosh users dumped"

Alan Cox circa 1999.

http://lists.freedesktop.org/archives/xorg/2007-August/027419.html

"well I'd be quite happy to see X go GPL but I'm aware
thats not the intention of the project ;)"

Alan Cox circa 2007.

What changed? Why are you guys setting out to break all of the
work underpinning UNIX and the Internet done in the 80s at
Berkeley? The reason the protocols and infrastructure took
off in the first place is due to liberal licenses that let everyone
be involved, not wrapping things up in more restrictions and lawyers.
