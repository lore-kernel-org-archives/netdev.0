From: Harald Welte <laforge@netfilter.org>
Subject: Re: [netfilter-core] [2.6 patch] net/netfilter/nfnetlink*: make functions static
Date: Sat, 3 Sep 2005 10:27:38 +0200
Message-ID: <20050903082738.GB4415@rama.de.gnumonks.org>
References: <20050903012829.GF3657@stusta.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751390AbVICINt@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20050903012829.GF3657@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 03, 2005 at 03:28:29AM +0200, Adrian Bunk wrote:
> This patch makes needlessly global functions static.

Thanks for your patch.  I'll merge it with my local changes (it clashes,
since the "htonll" implementation was removed) and submit it via davem
later today.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDGV56XaXGVTD0i/8RAkS1AKCJjj7M1eQ1HWVQXmOQtJYY9RIZqACdHoqM
0lGazA6+53mP44pXIl6lhyg=
=7Q2Y
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--
