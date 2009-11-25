From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: Add SHA384 and SHA512 HMAC authentication
	algorithms to XFRM
Date: Wed, 25 Nov 2009 20:11:40 +0800
Message-ID: <20091125121140.GB28385@gondor.apana.org.au>
References: <1259146719-16359-1-git-send-email-martin@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Martin Willi <martin@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39399 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758721AbZKYMLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 07:11:37 -0500
Content-Disposition: inline
In-Reply-To: <1259146719-16359-1-git-send-email-martin@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 25, 2009 at 11:58:39AM +0100, Martin Willi wrote:
> These algorithms use a truncation of 192/256 bits, as specified
> in RFC4868.
> 
> Signed-off-by: Martin Willi <martin@strongswan.org>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
