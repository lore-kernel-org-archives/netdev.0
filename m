From: David Miller <davem@davemloft.net>
Subject: Re: [-mm patch] unexport raise_softirq_irqoff
Date: Wed, 12 Sep 2007 06:15:39 -0700 (PDT)
Message-ID: <20070912.061539.35030920.davem@davemloft.net>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
	<20070909202544.GV3563@stusta.de>
	<20070909204153.GB11764@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:35968
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757632AbXILNP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:15:58 -0400
In-Reply-To: <20070909204153.GB11764@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Sun, 9 Sep 2007 21:41:53 +0100

> On Sun, Sep 09, 2007 at 10:25:44PM +0200, Adrian Bunk wrote:
> > On Fri, Aug 31, 2007 at 09:58:22PM -0700, Andrew Morton wrote:
> > >...
> > > Changes since 2.6.23-rc3-mm1:
> > >...
> > >  git-net.patch
> > >...
> > >  git trees
> > >...
> > 
> > raise_softirq_irqoff no longer has any modular user.
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> This should probably go in through Dave's tree as it's removing this
> rather annoying user.

Yep, I've just tossed it into my tree.

Thanks.
