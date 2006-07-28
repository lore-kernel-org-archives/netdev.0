From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3] add netdev_alloc_skb
Date: Fri, 28 Jul 2006 10:27:12 +0200
Message-ID: <20060728082712.GA27366@lst.de>
References: <20060726113136.GA403@lst.de> <20060726.152451.35043090.davem@davemloft.net> <20060728070851.GB25174@lst.de> <20060728.012424.70217564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:42411 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1751969AbWG1I1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 04:27:34 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060728.012424.70217564.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 01:24:24AM -0700, David Miller wrote:
> From: Christoph Hellwig <hch@lst.de>
> Date: Fri, 28 Jul 2006 09:08:51 +0200
> 
> > Yes, Joe Perches already pointed that out in private.  This typo is copy
> > and pasted from the dev_alloc_skb kerneldoc, so this patch fixes up all
> > four occurances:
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Please respin your original patch with this fixup, thanks
> a lot Christoph.

We need a fixup patch for the existing wrong comments on dev_alloc_skb
anyway - but if you prefer to respin the netdev_alloc_skb and have
another patch to fixup the original comments I can do that aswell.
