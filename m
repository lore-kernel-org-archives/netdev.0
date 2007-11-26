From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25] Fix pcounter build error without CONFIG_SMP
Date: Mon, 26 Nov 2007 23:36:16 +0800
Message-ID: <20071126153616.GH28022@gondor.apana.org.au>
References: <Pine.LNX.4.64.0711261630020.18529@kivilampi-30.cs.helsinki.fi> <20071126152305.GD14520@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3986 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751129AbXKZPg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 10:36:27 -0500
Content-Disposition: inline
In-Reply-To: <20071126152305.GD14520@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 01:23:05PM -0200, Arnaldo Carvalho de Melo wrot=
e:
> Em Mon, Nov 26, 2007 at 04:35:38PM +0200, Ilpo J=E4rvinen escreveu:
> >=20
> > I keep getting this build error and couldn't find anyone fixing
> > it in archives. ...Maybe all net developers except me build
> > just SMP kernels :-).
>=20
> Thank you! UP is for sissies anyway :-P
>=20
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Ilpo, you need a new machine :)

Thanks for fixing this! Patch applied to net-2.6.25.
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
