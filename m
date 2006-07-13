From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Thu, 13 Jul 2006 23:29:19 +0200
Message-ID: <20060713212919.GA28412@lst.de>
References: <20060707155255.10f2e10f@dxpl.pdx.osdl.net> <20060707.165527.77037268.davem@davemloft.net> <20060708104811.GB31751@lst.de> <20060708.133738.123994596.davem@davemloft.net> <20060713203615.GA26954@lst.de> <20060713142440.0e487717@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:24222 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1030404AbWGMV3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 17:29:34 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060713142440.0e487717@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> What's the new name? For sanity, don't reuse the name dev_alloc_skb.

dev_alloc_skb.  It's the by far sanest name for it, while the old
usage without dev argument was misleading.

