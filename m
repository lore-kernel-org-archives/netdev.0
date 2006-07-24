From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Mon, 24 Jul 2006 15:31:48 -0700 (PDT)
Message-ID: <20060724.153148.27446041.davem@davemloft.net>
References: <20060707090956.GA2543@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37543
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932302AbWGXWbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 18:31:38 -0400
To: hch@lst.de
In-Reply-To: <20060707090956.GA2543@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Fri, 7 Jul 2006 11:09:57 +0200

> dev_alloc_skb is designated for RX descriptors, not TX.  (Some drivers
> use it for the latter anyway, but that's a different story)
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Also applied, thanks a lot.
