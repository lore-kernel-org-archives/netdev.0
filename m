From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <courmisch@via.ecp.fr>
Subject: Re: (usagi-users 03222) Re: support of IPv6 by NFS
Date: Tue, 1 Mar 2005 17:35:01 +0100
Message-ID: <200503011735.01578.courmisch@via.ecp.fr>
References: <42243F8D.5030302@bull.net> <200503010744.38339.Info@Quantum-Sci.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2081891.0kPmRnMEtL";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Quantum Scientific <Info@Quantum-Sci.com>, netdev@oss.sgi.com
To: usagi-users@linux-ipv6.org
In-Reply-To: <200503010744.38339.Info@Quantum-Sci.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2081891.0kPmRnMEtL
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Le Mardi 1 Mars 2005 14:44, Quantum Scientific a =E9crit :
> And 80% of potential users are behind a cable/DSL 4 NATting router.=20
> There is no clarity that it is possible overcome this by either
> setting to DMZ, or hoping your cablemodem passes protos 41, 50 & 51.=20
> Even some tunnel operators do not know this, so I had to figure it
> out myself.  There is no Linux 6to4 UDP tunnelling app, but there
> should be, because this is such a common problem.  (As I understand,
> Teredo is Winduhs-only, and is not supported by most tunnel
> operators)

There is at least one Teredo client for Linux :
http://www.simphalempin.com/dev/miredo/

Alternatively, TSP tunneling might also work through NAT devices.

=2D-=20
R=E9mi Denis-Courmont

--nextPart2081891.0kPmRnMEtL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQBCJJm1w+xtvt1tEr0RAr9OAJ9EzYHS98Cw17gsQTbeDT75JSZZmQCfbyPD
9M1wuf6dIaHA2WbGMMtzEGg=
=SjbA
-----END PGP SIGNATURE-----

--nextPart2081891.0kPmRnMEtL--
