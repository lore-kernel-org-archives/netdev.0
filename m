From: David Miller <davem@davemloft.net>
Subject: Re: [1/2] [IPV4]: Uninline inet_lookup_listener
Date: Tue, 08 Aug 2006 02:21:47 -0700 (PDT)
Message-ID: <20060808.022147.35503970.davem@davemloft.net>
References: <20060808084614.GA6651@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21161
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750958AbWHHJVn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 05:21:43 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060808084614.GA6651@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 8 Aug 2006 18:46:14 +1000

> [IPV4]: Uninline inet_lookup_listener
> 
> By modern standards this function is way too big to be inlined.  It's
> even bigger than __inet_lookup_listener :)
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
