From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25] Cleanup IN_DEV_MFORWARD macro
Date: Sat, 8 Dec 2007 09:37:29 +0800
Message-ID: <20071208013729.GA16140@gondor.apana.org.au>
References: <4759729A.4030403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1344 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751841AbXLHBhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 20:37:33 -0500
Content-Disposition: inline
In-Reply-To: <4759729A.4030403@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 07, 2007 at 07:19:38PM +0300, Pavel Emelyanov wrote:
> This is essentially IN_DEV_ANDCONF with proper arguments.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks Pavel! I must have written that one before writing the
AND macro :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
