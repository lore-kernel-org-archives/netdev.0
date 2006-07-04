From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/5] af_unix datagram getpeersec fix
Date: Mon, 03 Jul 2006 19:26:30 -0700 (PDT)
Message-ID: <20060703.192630.104030932.davem@davemloft.net>
References: <200606300927.k5U9RLBD001462@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cxzhang@watson.ibm.com,
	herbert@gondor.apana.org.au, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51886
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751353AbWGDC0O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:26:14 -0400
To: akpm@osdl.org
In-Reply-To: <200606300927.k5U9RLBD001462@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Fri, 30 Jun 2006 02:27:21 -0700

> From: Andrew Morton <akpm@osdl.org>
> 
> The unix_get_peersec_dgram() stub should have been inlined so that it
> disappears.
> 
> Cc: James Morris <jmorris@namei.org>
> Cc: Stephen Smalley <sds@tycho.nsa.gov>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Catherine Zhang <cxzhang@watson.ibm.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks Andrew.
