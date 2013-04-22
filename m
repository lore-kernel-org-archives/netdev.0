From: Ben Hutchings <ben@decadent.org.uk>
Subject: net: drop dst before queueing fragments
Date: Mon, 22 Apr 2013 03:09:32 +0100
Message-ID: <1366596572.3408.138.camel@deadeye.wl.decadent.org.uk>
References: <20130418212842.GA18291@grsecurity.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tNc9Q2lCNpMD/98CTZvG"
Cc: Brad Spengler <spender@grsecurity.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130418212842.GA18291@grsecurity.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-tNc9Q2lCNpMD/98CTZvG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-04-18 at 17:28 -0400, Brad Spengler wrote:
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=
=3D97599dc792b45b1669c3cdb9a4b365aad0232f65
>=20
> Commit introducing error was from 2010, initial fix from 2011
>=20
> Fix does not apply cleanly against 3.8 even

David, please add this to your stable queue.

Ben.

--=20
Ben Hutchings
Klipstein's 4th Law of Prototyping and Production:
                                    A fail-safe circuit will destroy others=
.

--=-tNc9Q2lCNpMD/98CTZvG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUXSb3Oe/yOyVhhEJAQreOg//d5tJN0DYfUS7KZpzShYkAkbKl7Sg8FfP
H1KWboKzG22agUZtNk0bwLWqs8zmzuK9zq139hagW/lBU6vijnKagSmBDPXU3jmC
t1kTeCl/q1DTxCX/o5IkvVOXJin9oOx+IPhg5kjeCnHzyi/XT2Mgx3jllpx9OGDH
GakcGelW+Ym3GfQtilvSPGylI2q8E0IvLzcRPm5cm5HEBqu6FcGfGuY3dxF7EIpR
+uIdvnU5Wrb47hGucEj/VIzFox7fgNDbJoDVId0ZkkYpn241Efsy6UKEgzvfNUuB
Zt9MdQXhs/QgOGm49ZctcyLaCF5Tmjhp2n2vek0QtdRaaYEzQVx5VMEEOaY/djl6
ayjRYnNtBQ8koshrYbr9ansXkYwNUEAhvNVvPY4L+/H8n02EfuPdPtvALnNkF+Qz
VzstXR/cfT/cTFgi3VAXsNpVDB907Z9mU72w75M0UfspK+b4Ssct9oznJbSRHc6j
dRXjJj58WASUMIJQDOAY0/yYS3zRbpnDT+u0QDdoTEDv5p32wcg/lbFax1M+sQsi
7FSDva3an8qQKIp0p3dORvvFMpQqfin9+yeHn4QR7RDK4e6kgdSBHaXYrVPvp4FH
6viZ2PzQ8GWyzkhpJabzKeG0dhGVyjVd0iGciQjOm9svzsOBvdM6te/1jaL6+fmy
j4zMBrbpZIg=
=QUUO
-----END PGP SIGNATURE-----

--=-tNc9Q2lCNpMD/98CTZvG--
