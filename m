From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv6: Keep index within tab_unreach[]
Date: Mon, 6 Jul 2009 09:03:20 +0800
Message-ID: <20090706010320.GA15156@gondor.apana.org.au>
References: <4A37E715.4060504@gmail.com> <20090705034655.GA7635@gondor.apana.org.au> <20090705.155215.20761447.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42959 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754013AbZGFBDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 21:03:24 -0400
Content-Disposition: inline
In-Reply-To: <20090705.155215.20761447.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 05, 2009 at 03:52:15PM -0700, David Miller wrote:
>
> type and code should both be "u8"'s, we made a similar
> conversio of a family of ipv6 function arguments recently.
> 
> Actually, it's already there and done to this very function.
> 
> Herbert, this is just an ancient patch that has been superceded
> by the very change you are suggestions :-)

Yeah I know, was just reading old emails backwards :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
