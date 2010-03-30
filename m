From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/7] flow: delayed deletion of flow cache entries
Date: Tue, 30 Mar 2010 20:22:17 +0800
Message-ID: <20100330122217.GF5731@gondor.apana.org.au>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-5-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:32883 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932091Ab0C3MWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 08:22:19 -0400
Content-Disposition: inline
In-Reply-To: <1269871964-5412-5-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 05:12:41PM +0300, Timo Teras wrote:
> Speed up lookups by freeing flow cache entries later. This is also in
> preparation to have virtual entry destructor that might do more
> work.

So how does this speed up lookups exactly?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
