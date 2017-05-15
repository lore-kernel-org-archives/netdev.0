From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [PATCH net] ipv6: sr: fix user space compilation error with old
 glibc
Date: Mon, 15 May 2017 12:37:29 +0200
Message-ID: <fa27cb59-a81e-7f74-7d3f-7feb6d8406f1@uclouvain.be>
References: <20170515091828.19349-1-david.lebrun@uclouvain.be>
 <59197D53.8030104@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="OBGjHMnHjK61XfDbt2vGDUViwAkNPt5db"
Cc: <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:56608 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdEOKhD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 06:37:03 -0400
In-Reply-To: <59197D53.8030104@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--OBGjHMnHjK61XfDbt2vGDUViwAkNPt5db
Content-Type: multipart/mixed; boundary="2js2MnG9pcs0J0tlW5WfSb3v5TKvxFOKW"
From: David Lebrun <david.lebrun@uclouvain.be>
To: Daniel Borkmann <daniel@iogearbox.net>
Cc: netdev@vger.kernel.org
Message-ID: <fa27cb59-a81e-7f74-7d3f-7feb6d8406f1@uclouvain.be>
Subject: Re: [PATCH net] ipv6: sr: fix user space compilation error with old
 glibc
References: <20170515091828.19349-1-david.lebrun@uclouvain.be>
 <59197D53.8030104@iogearbox.net>
In-Reply-To: <59197D53.8030104@iogearbox.net>

--2js2MnG9pcs0J0tlW5WfSb3v5TKvxFOKW
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/15/2017 12:05 PM, Daniel Borkmann wrote:
>=20
> Or, is there still another fix for iproute2 coming after this has
> landed?

Yes, I will submit the fix to iproute2 once this one has been applied,
so that I can reference it.

David


--2js2MnG9pcs0J0tlW5WfSb3v5TKvxFOKW--

--OBGjHMnHjK61XfDbt2vGDUViwAkNPt5db
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQT8nTbQ2eQR5sQwCJ+NvOfruxnoAwUCWRmE6QAKCRCNvOfruxno
A0RyAJ0ZBsGnFCiARM4m5FxGgF68MlMHiQCfcvskUalS+rv2xgr3C42bz5bAAxE=
=n0uv
-----END PGP SIGNATURE-----

--OBGjHMnHjK61XfDbt2vGDUViwAkNPt5db--
