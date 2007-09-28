From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] sb1250-mac: Driver model & phylib update
Date: Fri, 28 Sep 2007 17:23:00 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0709281628130.10439@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.64N.0709191811040.24627@blysk.ds.pg.gda.pl>
 <20070921124409.7f3d122b.akpm@linux-foundation.org>
 <Pine.LNX.4.64N.0709241529570.22491@blysk.ds.pg.gda.pl>
 <20070924095559.c81f7061.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:35925 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648AbXI1QXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 12:23:10 -0400
In-Reply-To: <20070924095559.c81f7061.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Sep 2007, Andrew Morton wrote:

> >  Well, this is against Jeff's netdev-2.6 tree which hopefully is not as 
> > crufty as Linus's old mainline; if it is not possible to queue this change 
> > for 2.6.25 or suchlike, then I will try to resubmit later.
> 
> Most of Jeff's netdev tree got dumped into Dave's net-2.6.24 tree.  That's
> the one you want to be raising patches against for the next few weeks.

 OK, thanks for clarification.  Then both patches already submitted:

patch-netdev-2.6.23-rc6-20070920-sb1250-mac-typedef-9
patch-netdev-2.6.23-rc6-20070920-sb1250-mac-29

apply cleanly to net-2.6.24 one on top of the other in this order.

 I can resubmit them -- where?  netdev?  As I say I am fine with 2.6.25 as 
the target.

  Maciej
