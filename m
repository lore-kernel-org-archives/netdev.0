From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: time for TCP ECN defaulting to on?
Date: Sun, 16 Nov 2008 17:13:06 +0800
Message-ID: <E1L1dgo-0007pG-SL@gondolin.me.apana.org.au>
References: <20081104.145242.112948002.davem@davemloft.net>
Cc: linux-kernel@blueteddy.net, daniel.blueman@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34509 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751618AbYKPJNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 04:13:17 -0500
In-Reply-To: <20081104.145242.112948002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> This is because TSO, which is on by default, doesn't support ECN
> in many implementations.

Dave, we fixed that ages ago.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
