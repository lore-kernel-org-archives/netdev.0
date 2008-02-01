From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/1]: Add support for aes-ctr to ipsec
Date: Sat, 2 Feb 2008 10:51:15 +1100
Message-ID: <20080201235114.GA24156@gondor.apana.org.au>
References: <200801311659.m0VGxSTN025939@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48044 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753121AbYBAXvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 18:51:22 -0500
Content-Disposition: inline
In-Reply-To: <200801311659.m0VGxSTN025939@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 10:59:28AM -0600, Joy Latten wrote:
> Very sorry, re-posting as first patch was incomplete.
> 
> The below patch allows IPsec to use CTR mode with
> AES encryption algorithm. Tested this using setkey
> in ipsec-tools.
> 
> regards,
> Joy
> 
> 
> Signed-off-by: Joy Latten <latten@austin.ibm.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
