From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM]: Fix protocol field value for outgoing IPv6 GSO packets
Date: Tue, 25 Jul 2006 10:13:26 +1000
Message-ID: <20060725001326.GA18972@gondor.apana.org.au>
References: <44C56136.50600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:5127 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932349AbWGYANd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 20:13:33 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44C56136.50600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 25, 2006 at 02:09:26AM +0200, Patrick McHardy wrote:
> This appears to be a mistake, but I didn't follow the GSO stuff
> very closely, so there could be some non-obvious reason.

Yes it definitely was a mistake! Thanks for picking this up Patrick.

> [XFRM]: Fix protocol field value for outgoing IPv6 GSO packets
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
