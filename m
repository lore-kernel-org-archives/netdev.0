From: David Hollis <dhollis@davehollis.com>
Subject: Network driver test suite?
Date: Wed, 05 Jan 2005 15:19:46 -0500
Message-ID: <1104956386.3877.58.camel@dhollis-lnx.centricconsulting.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-iN/CSXxyVrLxrJOpvhY/"
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-iN/CSXxyVrLxrJOpvhY/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Is there any kind of test suite (automated or list of tests) available
for testing Linux network drivers?  I'm completing the addition of a few
new USB ethernet devices and would like to able to test all possible
scenarios instead of coming across them piece-meal in the future.  I'm
not a big fan of the "works on my box" testing that I'm doing now.  I'm
sure there are all kinds of things that I'm not testing that aren't
everyday types of things such as VLANs, multicasting, various
ethtool/mii-tool things, large packets, etc.

If there isn't anything like this, maybe it would be a useful thing to
develop?  At a minimum, maybe to set the treshhold for minimum features
that drivers support and the like.

--=20
David Hollis <dhollis@davehollis.com>

--=-iN/CSXxyVrLxrJOpvhY/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBB3EvhxasLqOyGHncRAgMDAKCO/pkUIwy3BdKNud9stqyPDF/VZgCfXiWi
zIyyHfUy0G/ue6WPaUnMhmI=
=QxIc
-----END PGP SIGNATURE-----

--=-iN/CSXxyVrLxrJOpvhY/--
