From: Harald Welte <laforge@netfilter.org>
Subject: Re: [ANNOUNCE] Porting MPLS-Linux to 2.6 (2.6.0-test9-bk22) comments welcome.
Date: Sat, 22 Nov 2003 09:55:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031122085557.GA2745@obroa-skai.de.gnumonks.org>
References: <Pine.SOL.4.40.0311180035340.18795-100000@gervaise.enst.fr> <1069125993.1056.39.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qDbXVdCdHGoSgWSk"
Cc: Ramon Casellas <casellas@infres.enst.fr>, mpls-linux-general@sf.net,
        "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1069125993.1056.39.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 17, 2003 at 10:26:34PM -0500, jamal wrote:
> Did you actually talk to James Leu before embarking on this rather
> valiant effort? If you did he may have warned you that the code was
> being rewritten from scratch. The code rewrite belongs to Dave Miller;
> i am adding user space support. James has been invited to look at that
> code once it is deemed working. If you want to be on the list as well,
> let me know. I am sure you as will James will both have valuable input.

now that is interesting.  I have a working patch for adding netfilter
hooks to the old MPLS stack.  If your rewrite doesn't yet have some,
I'll gladly add them.

I also have a working implementation of the draft-ietf-mpls-lsp-ping-01
based on the netfilter hooks for James Leu's MPLS implementation, btw.

> cheers,
> jamal

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--qDbXVdCdHGoSgWSk
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/vySdXaXGVTD0i/8RAsRkAKCKaz6vCPFy9lQ9Y/Gifs+CPWGtkgCfbe7N
4dl6fuBLhhKkNCft8ERmkJw=
=gadv
-----END PGP SIGNATURE-----

--qDbXVdCdHGoSgWSk--
