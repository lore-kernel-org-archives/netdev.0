From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 09:33:29 +1100
Message-ID: <20090121223329.GA8522@gondor.apana.org.au>
References: <1232523247-6893-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41782 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753228AbZAUWde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 17:33:34 -0500
Content-Disposition: inline
In-Reply-To: <1232523247-6893-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> wrote:
> Parse and send SADB_X_EXT_NAT_T_OA along with other NAT-T extensions.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Whatever application that you have in mind that's going to use
this should switch over to netlink.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
