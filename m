From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] sb1250-mac: Driver model & phylib update
Date: Mon, 24 Sep 2007 15:41:54 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0709241529570.22491@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.64N.0709191811040.24627@blysk.ds.pg.gda.pl>
 <20070921124409.7f3d122b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759382AbXIXOmZ@vger.kernel.org>
In-Reply-To: <20070921124409.7f3d122b.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Sep 2007, Andrew Morton wrote:

> >  A driver model and phylib update.
> 
> akpm:/usr/src/25> diffstat patches/git-net.patch | tail -n 1
>  1013 files changed, 187667 insertions(+), 23587 deletions(-)
> 
> Sorry, but raising networking patches against Linus's crufty
> old mainline tree just isn't viable at present.

 Well, this is against Jeff's netdev-2.6 tree which hopefully is not as 
crufty as Linus's old mainline; if it is not possible to queue this change 
for 2.6.25 or suchlike, then I will try to resubmit later.  Thanks for 
your attention though.

  Maciej
