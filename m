From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/7] flow: structurize flow cache
Date: Tue, 30 Mar 2010 20:15:42 +0800
Message-ID: <20100330121542.GE5731@gondor.apana.org.au>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-3-git-send-email-timo.teras@iki.fi> <20100330120104.GB5731@gondor.apana.org.au> <4BB1E862.8090302@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:34676 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756551Ab0C3MPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 08:15:44 -0400
Content-Disposition: inline
In-Reply-To: <4BB1E862.8090302@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 03:02:42PM +0300, Timo Ter=E4s wrote:
>
> If we want generic flow cache, we might want to have multiple
> instance in future. It might also make sense to have per-net
> flow cache.

OK that makes sense.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
