From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] add netdev_alloc_skb
Date: Fri, 28 Jul 2006 01:24:24 -0700 (PDT)
Message-ID: <20060728.012424.70217564.davem@davemloft.net>
References: <20060726113136.GA403@lst.de>
	<20060726.152451.35043090.davem@davemloft.net>
	<20060728070851.GB25174@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50611
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750841AbWG1IYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 04:24:46 -0400
To: hch@lst.de
In-Reply-To: <20060728070851.GB25174@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Fri, 28 Jul 2006 09:08:51 +0200

> Yes, Joe Perches already pointed that out in private.  This typo is copy
> and pasted from the dev_alloc_skb kerneldoc, so this patch fixes up all
> four occurances:
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Please respin your original patch with this fixup, thanks
a lot Christoph.
