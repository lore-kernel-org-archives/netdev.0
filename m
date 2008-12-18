From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Fri, 19 Dec 2008 09:36:51 +1100
Message-ID: <20081218223651.GA1574@gondor.apana.org.au>
References: <1229638581.3726.546.camel@calx> <Pine.LNX.4.64.0812190028560.12061@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Mackall <mpm@selenic.com>, David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60379 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752371AbYLRWhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 17:37:06 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0812190028560.12061@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 10:33:46PM +0000, Ilpo J=E4rvinen wrote:
>=20
> Last time (well, ignoring some report on ancient vendor kernel) I've =
seen=20
> this to trigger it wasn't the fault of the peer but ours (we sent pas=
t the=20
> advertized window and window ended up being shrunk to zero). I agree =
that=20
> the message as-is is not very good but your change is not very good=20
> either.

Indeed I had fixed a bug in our kernel that triggered this too
so this is definitely treason :)

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
