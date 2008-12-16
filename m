From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] e1000e: Add GRO support
Date: Mon, 15 Dec 2008 23:46:31 -0800 (PST)
Message-ID: <20081215.234631.250444955.davem@davemloft.net>
References: <20081213013420.GA13549@gondor.apana.org.au>
	<E1LBJPi-0003ZL-Qr@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johnpol@2ka.mipt.ru,
	bhutchings@solarflare.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38033
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751169AbYLPHqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 02:46:31 -0500
In-Reply-To: <E1LBJPi-0003ZL-Qr@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 13 Dec 2008 12:35:26 +1100

> e1000e: Add GRO support
> 
> This patch adds GRO support to e1000e by making it invoke napi_gro_receive
> instead of netif_receive_skb.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks a lot Herbert.
