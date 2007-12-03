From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25] TCP: Fix copy-paste (or code move) error
Date: Mon, 3 Dec 2007 22:17:14 +1100
Message-ID: <20071203111714.GA30111@gondor.apana.org.au>
References: <Pine.LNX.4.64.0712021841050.11818@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4560 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753802AbXLCLRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 06:17:21 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0712021841050.11818@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 02, 2007 at 06:45:44PM +0200, Ilpo J=E4rvinen wrote:
> Should get the skb from the same queue. I had it first elsewhere
> and missed this change while moving.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied to net-2.6.25.  Thanks Ilpo!
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
