From: "Michael B. Trausch" <mike@trausch.us>
Subject: Re: NULL pointer derefence since 2.6.27 in (e)poll
Date: Sat, 25 Oct 2008 20:03:43 -0400
Message-ID: <20081025200343.08dc7999@zest>
References: <fa.tyZSmpETPCXhUoPJmJ8KenIDR9A@ifi.uio.no>
	<fa.LCxpt1ZiVhg13wi1ociM3pxlA5Y@ifi.uio.no>
	<fa.OzlOaDLw1wzOiIOE3c5y1CNHYtk@ifi.uio.no>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/wxqRVD.dYcTx9N7UiOtEd9f";
 protocol="application/pgp-signature"; micalg=PGP-RIPEMD160
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:55241 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbYJZADx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2008 20:03:53 -0400
Received: by yw-out-2324.google.com with SMTP id 9so433998ywe.1
        for <netdev@vger.kernel.org>; Sat, 25 Oct 2008 17:03:51 -0700 (PDT)
In-Reply-To: <fa.OzlOaDLw1wzOiIOE3c5y1CNHYtk@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/wxqRVD.dYcTx9N7UiOtEd9f
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 19 Oct 2008 12:48:00 UTC
Hugh Dickins <hugh@veritas.com> wrote:
>=20
> Isn't it the issue fixed by
>=20
> http://marc.info/?l=3Dlinux-kernel&m=3D122428548613067&w=3D2
>=20

Is there a reason that this patch has not yet been applied to the Linux
kernel?  I just found this thread and had to apply this patch to
2.6.28-rc1.

Shouldn't it go into 2.6.28?

	--- Mike

--=20
My sigfile ran away and is on hiatus.
http://www.trausch.us/

--Sig_/wxqRVD.dYcTx9N7UiOtEd9f
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEAREDAAYFAkkDs98ACgkQ0kE/IBnFmjBetgCcCLASeDvV2mOkhOWxhKLSn8N6
b3wAniAJjQKVHQ/XZAOcZBQ7bcCIWc40
=pt6b
-----END PGP SIGNATURE-----

--Sig_/wxqRVD.dYcTx9N7UiOtEd9f--
