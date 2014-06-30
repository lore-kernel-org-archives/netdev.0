From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm4: Remove duplicate semicolon
Date: Mon, 30 Jun 2014 11:20:20 +0200
Message-ID: <20140630092020.GP32371@secunet.com>
References: <1403957564-6069-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58524 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514AbaF3JU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2014 05:20:26 -0400
Content-Disposition: inline
In-Reply-To: <1403957564-6069-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 28, 2014 at 02:12:44PM +0200, Christoph Paasch wrote:
> 3328715e6c1fc (xfrm4: Add IPsec protocol multiplexer) adds a
> duplicate semicolon after the return-statement.
> 
> Although it has no negative impact, the second semicolon should be
> removed.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied to ipsec-next, thanks!
