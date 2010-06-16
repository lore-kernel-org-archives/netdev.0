From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Fix OOM crash in deliver_clone
Date: Tue, 15 Jun 2010 21:43:18 -0700 (PDT)
Message-ID: <20100615.214318.91346815.davem@davemloft.net>
References: <20100616040219.GA18000@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mwagner@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44977
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751123Ab0FPEnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 00:43:08 -0400
In-Reply-To: <20100616040219.GA18000@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 16 Jun 2010 14:02:19 +1000

> Hi Dave:
> 
> bridge: Fix OOM crash in deliver_clone
> 
> The bridge multicast patches introduced an OOM crash in the forward
> path, when deliver_clone fails to clone the skb.
> 
> This patch fixes it.
> 
> Reported-by: Mark Wagner <mwagner@redhat.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
