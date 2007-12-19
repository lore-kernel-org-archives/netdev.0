From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: missing dir in and dir fwd policy on 2.6.23
Date: Wed, 19 Dec 2007 20:01:43 +0800
Message-ID: <E1J4xcN-0002P2-00@gondolin.me.apana.org.au>
References: <BAY103-DAV11DB3994E500651501D08B25C0@phx.gbl>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: pupilla@hotmail.com (Marco Berizzi)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3724 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753184AbXLSMXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 07:23:07 -0500
In-Reply-To: <BAY103-DAV11DB3994E500651501D08B25C0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi <pupilla@hotmail.com> wrote:
>
> Is this bug recently introduced? I'm using this
> config since 2.6.16/openswan 2.4.4 (two years).
> I haven't never noticed: now I must restart openswan
> once a day :-(

No it's been there forever but I haven't worked out exactly
what triggers it yet or I'd have already fixed it :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
