From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25] Make macro to specify the ptype_base size
Date: Mon, 26 Nov 2007 20:14:35 +0800
Message-ID: <20071126121435.GD26599@gondor.apana.org.au>
References: <4746D9F8.8010304@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2047 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754168AbXKZMOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 07:14:38 -0500
Content-Disposition: inline
In-Reply-To: <4746D9F8.8010304@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 04:47:36PM +0300, Pavel Emelyanov wrote:
> Currently this size is 16, but as the comment says this
> is so only because all the chains (except one) has the
> length 1. I think, that some day this may change, so 
> growing this hash will be much easier.
> 
> Besides, symbolic names are read better than magic constants.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.25.  Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
