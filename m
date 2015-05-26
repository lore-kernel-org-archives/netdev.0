From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD
 interface
Date: Tue, 26 May 2015 15:58:49 +0800
Message-ID: <20150526075849.GB6849@gondor.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
 <1720790.K1nOQU1Nxi@tachyon.chronox.de>
 <20150526073605.GA6530@gondor.apana.org.au>
 <5101027.rdCY05rkLJ@tauon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:59717 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbbEZH6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 03:58:54 -0400
Content-Disposition: inline
In-Reply-To: <5101027.rdCY05rkLJ@tauon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 26, 2015 at 09:57:51AM +0200, Stephan Mueller wrote:
>
> Ok. Would you look into that one or shall I do that?

I'll reenable it immediately after the patch to convert it to
the new interface is merged.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
