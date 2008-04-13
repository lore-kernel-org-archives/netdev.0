From: Adrian Bunk <bunk@kernel.org>
Subject: Re: Reporting bugs and bisection (was: Re: 2.6.25-rc8: FTP
	transfer errors)
Date: Sun, 13 Apr 2008 23:10:28 +0300
Message-ID: <20080413201028.GE13920@cs181133002.pp.htv.fi>
References: <47FEADCB.7070104@rtr.ca> <22880.1207943922@turing-police.cc.vt.edu> <47FFE5DA.8000709@imap.cc> <200804132040.12138.rjw@sisk.pl> <20080413184730.GD8474@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Tilman Schmidt <tilman@imap.cc>,
	Valdis.Kletnieks@vt.edu, Mark Lord <lkml@rtr.ca>,
	David Miller <davem@davemloft.net>, jesper.juhl@gmail.com,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:60993 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752635AbYDMUL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2008 16:11:29 -0400
Content-Disposition: inline
In-Reply-To: <20080413184730.GD8474@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 13, 2008 at 08:47:30PM +0200, Willy Tarreau wrote:
>...
> Very true. One other thing which might get confusing/frustrating on the
> user side is that currently, Linux is the *only* product which requires
> the bug reporter to find the fault change (yes, I know, it's scalable).
>...

That's not true, for several regressions I reported to the Wine Bugzilla 
I had been asked to git bisect for the commit that broke it.

And I'd actually assume that it's quite common for git using open source 
projects to ask the user to bisect regressions.

> Regards,
> Willy

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

