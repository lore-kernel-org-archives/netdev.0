From: Harald Welte <laforge@netfilter.org>
Subject: Re: Do you know about skb_header_pointer() ?
Date: Thu, 19 Aug 2004 18:55:21 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040819165521.GV3921@sunbeam.de.gnumonks.org>
References: <200408190721.QAA02944@toshiba.co.jp> <20040819094401.GY3921@sunbeam.de.gnumonks.org> <20040819071618.27515547.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cebYKQG0P13XUdCa"
Cc: yasuyuki.kozakai@toshiba.co.jp, kaber@trash.net,
	kadlec@blackhole.kfki.hu, kisza@securityaudit.hu,
	netfilter-devel@lists.netfilter.org, usagi-core@linux-ipv6.org,
	netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040819071618.27515547.davem@redhat.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--cebYKQG0P13XUdCa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 19, 2004 at 07:16:18AM -0700, David S. Miller wrote:
> On Thu, 19 Aug 2004 11:44:01 +0200
> Harald Welte <laforge@netfilter.org> wrote:
>=20
> > I personally still like Yasuyuki's implementation[1] better,
>=20
> Thanks for letting me know about this after we agreed upon
> skb_header_pointer() (or somthing like it) at the networking
> conference _AND_ I did the full implementation for you Harald.

No offence meant, Dave :)  I am grateful that you did this work, please
don't get me wrong.

> Or did you just learn about Ysauyuki's work recently?

Yasuyiki's first implementation dates July 29th. =20
The one that I'm referring to was a patch from August 8th.

The netconf discussion predates any of this.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--cebYKQG0P13XUdCa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBJNt5XaXGVTD0i/8RAqqbAKCNB5gPoYHCTbGHWgcp897BbPkNCACfeCpH
9c32exKnqh9a/frMA6SOtoI=
=oUWg
-----END PGP SIGNATURE-----

--cebYKQG0P13XUdCa--
