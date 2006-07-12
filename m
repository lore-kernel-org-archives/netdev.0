From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 6688] Memory allocation problem
Date: Wed, 12 Jul 2006 13:30:38 -0700 (PDT)
Message-ID: <20060712.133038.05331476.davem@davemloft.net>
References: <20060620002433.28115714.akpm@osdl.org>
	<E1G0d94-0004My-00@gondolin.me.apana.org.au>
	<20060712114513.GA16823@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, pstaszewski@artcom.pl,
	Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4765
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751207AbWGLU3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 16:29:47 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060712114513.GA16823@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 12 Jul 2006 21:45:13 +1000

> [IPV4]: Fix error handling for fib_insert_node call
> 
> The error handling around fib_insert_node was broken because we always
> zeroed the error before checking it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
