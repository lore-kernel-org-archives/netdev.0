From: David Miller <davem@davemloft.net>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 20:46:47 -0700 (PDT)
Message-ID: <20100519.204647.94872920.davem@davemloft.net>
References: <20100520025741.GA6129@gondor.apana.org.au>
	<20100519.200522.140743640.davem@davemloft.net>
	<20100520033446.GA6434@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bmb@athenacr.com, tgraf@redhat.com, nhorman@tuxdriver.com,
	nhorman@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46158
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753553Ab0ETDqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 23:46:38 -0400
In-Reply-To: <20100520033446.GA6434@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 20 May 2010 13:34:46 +1000

> cls_cgroup: Store classid in struct sock

This looks great to me.
