From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.12-rc4-mm[12] - ULOG problem
Date: Fri, 20 May 2005 10:25:27 +0400
Message-ID: <1116570327.21310.106.camel@uganda>
References: <Xine.LNX.4.44.0505190915010.15522-100000@thoron.boston.redhat.com>
	 <1116510411.6240.54.camel@localhost.localdomain>
	 <20050519.114901.108984882.davem@davemloft.net>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-zXmMmqNM4Ni1K8Sx1ErA"
Cc: hadi@cyberus.ca, jmorris@redhat.com, akpm@osdl.org,
        herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050519.114901.108984882.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-zXmMmqNM4Ni1K8Sx1ErA
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2005-05-19 at 11:49 -0700, David S. Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Thu, 19 May 2005 09:46:50 -0400
>=20
> > However, something like connector should only get one ID and it can do
> > its own multiplexing based on "units".
>=20
> Yes.  There is no reason connector needs more than one
> netlink ID.

It does not require several IDs.

--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-zXmMmqNM4Ni1K8Sx1ErA
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCjYLXIKTPhE+8wY0RAobHAJ9FgefgAFZuAWC5OiJQorvLzRLI8gCfW0UU
8q/GgJQiTCqdcCjahh0rsp0=
=F+Z5
-----END PGP SIGNATURE-----

--=-zXmMmqNM4Ni1K8Sx1ErA--
