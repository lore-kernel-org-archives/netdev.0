From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Return EOVERFLOW when output sequence number overflows
Date: Wed, 2 Jan 2008 19:25:50 +1100
Message-ID: <20080102082550.GA26304@gondor.apana.org.au>
References: <20080102071619.GA23687@gondor.apana.org.au> <20080101.235342.183794044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2472 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752979AbYABIZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 03:25:54 -0500
Content-Disposition: inline
In-Reply-To: <20080101.235342.183794044.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 01, 2008 at 11:53:42PM -0800, David Miller wrote:
>
> It seems this was a regression added by Paul's patch in net-2.6.25 and
> not something that needs fixing in 2.6.24 and stable?

Yes this is brand new so we don't need it for 2.6.24.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
