From: Harald Welte <laforge@gnumonks.org>
Subject: Re: Troubles with NFS & ip_conntrack: packets go to wrong mac
Date: Thu, 13 Feb 2003 11:12:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030213101220.GC14794@sunbeam.de.gnumonks.org>
References: <3E4A7ECB.1020207@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kfjH4zxOES6UT95V"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <3E4A7ECB.1020207@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--kfjH4zxOES6UT95V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 12, 2003 at 06:05:15PM +0100, Patrick McHardy wrote:
> I've been experiencing strange problems with nfs and ip_conntrack for a=
=20
> while now, unfortunately noone so far was able to help. The problem
> occurs when ip_conntrack is loaded on the nfs server. nfs reads hang
> and the clients start logging

Just for consistency: Can you please report this to
http://bugzilla.netfilter.org/ ?=20

Addiditional information like what kind of machine (UP/SMP), and network
board might be interesting.

> Regards,
> Patrick

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"If this were a dictatorship, it'd be a heck of a lot easier, just so long
 as I'm the dictator."  --  George W. Bush Dec 18, 2000

--kfjH4zxOES6UT95V
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE+S2+EXaXGVTD0i/8RAs+BAJ9LJCE7pzlqnfJBuEMYYvku+0RpmwCgoG6S
MrzI6jBhSuyg9UO18VVNcLs=
=Cu4h
-----END PGP SIGNATURE-----

--kfjH4zxOES6UT95V--
