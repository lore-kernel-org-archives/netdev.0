From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Nicer WARN_ON in netstat_show
Date: Fri, 30 Nov 2007 00:43:01 +1100
Message-ID: <20071129134301.GH8487@gondor.apana.org.au>
References: <474D3ECC.8030703@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3863 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757460AbXK2NnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 08:43:04 -0500
Content-Disposition: inline
In-Reply-To: <474D3ECC.8030703@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2007 at 01:11:24PM +0300, Pavel Emelyanov wrote:
> The
> 
> 	if (statement)
> 		WARN_ON(1);
> 
> looks much better as
> 
> 	WARN_ON(statement);
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.25.  Thanks.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
