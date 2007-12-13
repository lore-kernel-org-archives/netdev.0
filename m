From: David Miller <davem@davemloft.net>
Subject: Re: [DECNET]: Fix inverted wait flag in xfrm_lookup call
Date: Thu, 13 Dec 2007 05:25:10 -0800 (PST)
Message-ID: <20071213.052510.258324538.davem@davemloft.net>
References: <20071213014623.GB32308@gondor.apana.org.au>
	<20071212.184919.157572948.davem@davemloft.net>
	<20071213052516.GA2134@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39436
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754207AbXLMNZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 08:25:11 -0500
In-Reply-To: <20071213052516.GA2134@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Dec 2007 13:25:16 +0800

> [DECNET]: Fix inverted wait flag in xfrm_lookup call
> 
> My previous patch made the wait flag take the opposite value to what it
> should be.  This patch fixes that.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
