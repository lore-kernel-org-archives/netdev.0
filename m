From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv4/ipvs/: remove unused exports
Date: Mon, 12 Nov 2007 00:01:37 -0800 (PST)
Message-ID: <20071112.000137.153691954.davem@davemloft.net>
References: <20071111064840.GJ21669@stusta.de>
	<20071111070939.GA25304@verge.net.au>
	<20071112075836.GE9771@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, rumen@voicecho.com, wensong@linux-vs.org,
	ja@ssi.bg, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lvs-devel@linuxvirtualserver.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34718
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753144AbXKLIBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 03:01:38 -0500
In-Reply-To: <20071112075836.GE9771@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 12 Nov 2007 08:58:36 +0100

> On Sun, Nov 11, 2007 at 04:09:40PM +0900, Simon Horman wrote:
> > On Sun, Nov 11, 2007 at 07:48:40AM +0100, Adrian Bunk wrote:
> > > This patch removes the following unused EXPORT_SYMBOL's:
> > > - ip_vs_try_bind_dest
> > > - ip_vs_find_dest
> > > 
> > > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> > 
> > Looks fine to me.
> > 
> > Should Dave Miller put this in his tree,
> > or do you want to handle it a different way?
> >...
> 
> If Dave applies it that would be perfect.

I will do this.
