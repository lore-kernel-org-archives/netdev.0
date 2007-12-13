From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Make callers of xfrm_lookup to use XFRM_LOOKUP_WAIT
Date: Wed, 12 Dec 2007 18:49:19 -0800 (PST)
Message-ID: <20071212.184919.157572948.davem@davemloft.net>
References: <E1J2GrH-0005SK-00@gondolin.me.apana.org.au>
	<20071212.104342.206132994.davem@davemloft.net>
	<20071213014623.GB32308@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58759
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751711AbXLMCtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 21:49:19 -0500
In-Reply-To: <20071213014623.GB32308@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Dec 2007 09:46:23 +0800

> [IPSEC]: Make callers of xfrm_lookup to use XFRM_LOOKUP_WAIT
> 
> This patch converts all callers of xfrm_lookup that used an
> explicit value of 1 to indiciate blocking to use the new flag
> XFRM_LOOKUP_WAIT.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
