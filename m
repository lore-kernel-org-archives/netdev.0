From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/24] [IPSEC]: Merge most of the input path
Date: Tue, 13 Nov 2007 21:44:34 -0800 (PST)
Message-ID: <20071113.214434.03791893.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplaA-0001If-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39577
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750779AbXKNFof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:44:35 -0500
In-Reply-To: <E1IplaA-0001If-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:38 +0800

> [IPSEC]: Merge most of the input path
> 
> As part of the work on asynchrnous cryptographic operations, we need to
> be able to resume from the spot where they occur.  As such, it helps if
> we isolate them to one spot.
> 
> This patch moves most of the remaining family-specific processing into
> the common input code.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
