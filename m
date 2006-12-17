From: Carlos =?ISO-8859-1?Q?Mart=EDn?= Nieto <carlos@cmartin.tk>
Subject: Bringing acx-d80211 up to date  (was: [Acx100-devel] Ping)
Date: Sun, 17 Dec 2006 20:04:12 +0100
Message-ID: <1166382252.9214.12.camel@localhost>
References: <1d9d9b240612170230i3bf44271sc331e102e65c7447@mail.gmail.com>
	 <em3q48$giu$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-tuxDgE28STE0GgtwXA7I"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 200.red-82-159-198.user.auna.net ([82.159.198.200]:48796 "EHLO
	indy.cmartin.tk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932215AbWLQTEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 14:04:11 -0500
To: acx100-devel@lists.sourceforge.net
In-Reply-To: <em3q48$giu$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-tuxDgE28STE0GgtwXA7I
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On dom, 2006-12-17 at 17:09 +0100, Matthias Steppuhn wrote:
> Hi all,
>=20
> Bernat Tallaferro wrote a wakeup call ;-)
>=20
> I'd suggest everyone still in the mood to contribute to issue his ping - =
or
> are we already fading away ?

 I think we faded away some time ago.

 I have however recently picked up the latest acx-d80211 tarball and am
preparing it for an eventual inclusion in the wireless-dev tree, so
hopefully development will pick up again.

 I'm going to release this tarball on my mirror and in the next few days
I'll apply my modularisation patch. This tarball has removed quite some
code and I have applied some patches from the wireless-2.6 branch.

(I've CC'd netdev, as we're supposed to have migrated there the
discussion some time ago. Also, sf.net doesn't like my mail server.)

>=20
>=20
> BT> I was thinking of updating the acx wiki=20

That'd be nice.

   cmn
--=20
Carlos Mart=C3=ADn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |


--=-tuxDgE28STE0GgtwXA7I
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBFhZSsEVXxXOiy6a4RApy4AJ41lq7y0dx1GFHZyqaY+S7wPinqMgCgoGxs
rb2fWBw/ofukw7NA76bsDyE=
=59EC
-----END PGP SIGNATURE-----

--=-tuxDgE28STE0GgtwXA7I--

