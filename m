From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] add netdev_alloc_skb
Date: Fri, 28 Jul 2006 01:28:32 -0700 (PDT)
Message-ID: <20060728.012832.99202035.davem@davemloft.net>
References: <20060728070851.GB25174@lst.de>
	<20060728.012424.70217564.davem@davemloft.net>
	<20060728082712.GA27366@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58760
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751152AbWG1I24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 04:28:56 -0400
To: hch@lst.de
In-Reply-To: <20060728082712.GA27366@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Fri, 28 Jul 2006 10:27:12 +0200

> We need a fixup patch for the existing wrong comments on dev_alloc_skb
> anyway - but if you prefer to respin the netdev_alloc_skb and have
> another patch to fixup the original comments I can do that aswell.

I intend to, for everyone's convenience, put the addition of
netdev_alloc_skb() into 2.6.18.
