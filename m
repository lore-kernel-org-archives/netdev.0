From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6 3/4] xfrm: Check for the new replay
	implementation if an esn state is inserted
Date: Tue, 26 Apr 2011 15:43:04 +1000
Message-ID: <20110426054304.GD18896@gondor.apana.org.au>
References: <20110426053923.GF5495@secunet.com> <20110426054121.GH5495@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:33454 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045Ab1DZFnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 01:43:10 -0400
Content-Disposition: inline
In-Reply-To: <20110426054121.GH5495@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 07:41:21AM +0200, Steffen Klassert wrote:
> IPsec extended sequence numbers can be used only with the new
> anti-replay window implementation. So check if the new implementation
> is used if an esn state is inserted and return an error if it is not.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
