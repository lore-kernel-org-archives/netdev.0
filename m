From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] udp: net-2.6.22 build fix
Date: Thu, 8 Mar 2007 08:51:48 +1100
Message-ID: <20070307215148.GA30424@gondor.apana.org.au>
References: <20070307134743.42e3b5c7@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1489 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2992641AbXCGVwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 16:52:15 -0500
Content-Disposition: inline
In-Reply-To: <20070307134743.42e3b5c7@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2007 at 01:47:43PM -0800, Stephen Hemminger wrote:
> Recent change broke build of UDP.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Thanks for that Stephen.  Somehow this one got away.  Perhaps we
can recode these macros so that they always get compiled-checked?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
