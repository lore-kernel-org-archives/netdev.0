From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.12-rc4-mm[12] - ULOG problem
Date: Fri, 20 May 2005 10:27:17 +0400
Message-ID: <1116570437.21310.109.camel@uganda>
References: <20050519000809.2fca25c5.akpm@osdl.org>
	 <Xine.LNX.4.44.0505190918430.15522-100000@thoron.boston.redhat.com>
	 <20050519.114813.85686672.davem@davemloft.net>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-nBDj0w30x2x6ERkyL24d"
Cc: jmorris@redhat.com, akpm@osdl.org, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050519.114813.85686672.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-nBDj0w30x2x6ERkyL24d
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2005-05-19 at 11:48 -0700, David S. Miller wrote:
> From: James Morris <jmorris@redhat.com>
> Date: Thu, 19 May 2005 09:19:33 -0400 (EDT)
>=20
> > On Thu, 19 May 2005, Andrew Morton wrote:
> >=20
> > > We should remove the feature.  If there is demonstrated need for mult=
iple
> > > instances then it should be done by more conventional means - syscall=
,
> > > allocation of a device major then use the minor as a selector or what=
ever.
> >=20
> > I'd suggest removing the connector code completely.
>=20
> I totally agree, it's crap at the current time and the author doesn't
> fix the problems being shown in it, in fact he defends some of them
> even this one.  It needs lots of work still.

There were no problems reported.
Completely.

What I defend is ability to function correctly when some changes=20
may be introduced by providing some extensions that may be used.

--=20
        Evgeniy Polyakov

Crash is better than data corruption -- Arthur Grabowski

--=-nBDj0w30x2x6ERkyL24d
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCjYNFIKTPhE+8wY0RAtoRAJ0Ufb586V3GnUmHmemEBTnY0SEZPACfU6u0
5yW0wq0s1Q9difSukvT27Ms=
=Pdlu
-----END PGP SIGNATURE-----

--=-nBDj0w30x2x6ERkyL24d--
