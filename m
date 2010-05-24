From: David Miller <davem@davemloft.net>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Sun, 23 May 2010 23:44:11 -0700 (PDT)
Message-ID: <20100523.234411.134420225.davem@davemloft.net>
References: <1274333779.2658.43.camel@edumazet-laptop>
	<20100520054642.GA7836@gondor.apana.org.au>
	<20100520065242.GA8719@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bmb@athenacr.com, tgraf@redhat.com,
	nhorman@tuxdriver.com, nhorman@redhat.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42458
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751430Ab0EXGoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:44:02 -0400
In-Reply-To: <20100520065242.GA8719@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 20 May 2010 16:52:42 +1000

> cls_cgroup: Store classid in struct sock
 ...
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
