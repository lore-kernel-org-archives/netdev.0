From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/11] [IPSEC]: Move tunnel parsing for IPv4 out of
 xfrm4_input
Date: Wed, 17 Oct 2007 21:29:02 -0700 (PDT)
Message-ID: <20071017.212902.68160683.davem@davemloft.net>
References: <20071017142940.GA23879@gondor.apana.org.au>
	<E1Ii9yL-0006Gp-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60280
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750787AbXJRE3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:29:05 -0400
In-Reply-To: <E1Ii9yL-0006Gp-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Oct 2007 22:34:09 +0800

> [IPSEC]: Move tunnel parsing for IPv4 out of xfrm4_input
> 
> This patch moves the tunnel parsing for IPv4 out of xfrm4_input and into
> xfrm4_tunnel.  This change is in line with what IPv6 does and will allow
> us to merge the two input functions.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
