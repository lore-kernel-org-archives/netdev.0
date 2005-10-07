From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Fri, 7 Oct 2005 04:38:02 +0200
Message-ID: <20051007023801.GA5953@rama>
References: <432EF0C5.5090908@cosmosbay.com> <200509281037.03185.ak@suse.de> <4342B575.9090709@trash.net> <200510051853.32196.ak@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/04w6evG8XlLl3ft"
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org,
	Henrik Nordstrom <hno@marasystems.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751253AbVJFRa4@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200510051853.32196.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 05, 2005 at 06:53:31PM +0200, Andi Kleen wrote:
> On Tuesday 04 October 2005 19:01, Patrick McHardy wrote:
> > Andi Kleen wrote:
> > > In a sense it's even getting worse: For example us losing the CONFIG
> > > option to disable local conntrack (Patrick has disabled it some time =
ago
> > > without even a comment why he did it) has a really bad impact in some
> > > cases.
> >
> > It was necessary to correctly handle locally generated ICMP errors.
>=20
> Well you most likely wrecked local performance then when it's enabled.

so you would favour a system that incorrectly deals with ICMP errors but
has higher performance?

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDRd+JXaXGVTD0i/8RAv8nAJ0VJn1aig7l8IyTAjs4MT5AnphWxQCfUv5E
k87CKliQJ2YXeGO2lH0cv48=
=kdbd
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--
