From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] (revised) Interfamily IPSec BEET
Date: Tue, 5 Aug 2008 18:51:25 +0800
Message-ID: <20080805105125.GB21786@gondor.apana.org.au>
References: <200808051235.42038.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yoshfuji@wide.ad.jp
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34813 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753289AbYHELZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 07:25:59 -0400
Content-Disposition: inline
In-Reply-To: <200808051235.42038.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 12:35:41PM +0300, Joakim Koskela wrote:
> 
> Here's a revised version, based on Herbert's comments, of a fix for
> the ipv6-inner, ipv4-outer interfamily ipsec beet mode. It fixes the
> network header adjustment in interfamily, and doesn't reserve space
> for the pseudo header anymore when we have ipv6 as the inner family.
> 
> Signed-off-by: Joakim Koskela <jookos@gmail.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
