From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless vs. network namespaces (part II)
Date: Mon, 29 Sep 2008 21:05:53 +0200
Message-ID: <1222715153.7064.42.camel@johannes.berg>
References: <1222509685.3798.59.camel@johannes.berg>
	 <m1r675aw0l.fsf@frodo.ebiederm.org>
	 <1222587651.3798.72.camel@johannes.berg>  <20080929190345.GD6203@tesla>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-PXCvc99EZlNgN6KcBu2J"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:50452 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbYI2TGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 15:06:00 -0400
In-Reply-To: <20080929190345.GD6203@tesla>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PXCvc99EZlNgN6KcBu2J
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-09-29 at 12:03 -0700, Luis R. Rodriguez wrote:

> > Right, except that wireless really is different in that for one you
> > can't really usefully have multiple virtual interfaces unless you're
> > making an AP
>=20
> Well it may be possible later in STA too, but that is just me looking at
> a crystal ball.

Well, it _is_ possible, but not standards compliant ;) Stefano is, I
think, the only person who has ever tested my firmware patch.

> > (and I think it's unlikely you'd want that in an AP, and
> > even if I'm not willing to support it,=20
>=20
> You mean AP VLANs? I thought you added that code already. I don't
> follow.

Well, I don't see a point in allowing them in different network
namespaces.

johannes

--=-PXCvc99EZlNgN6KcBu2J
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJI4ScOAAoJEKVg1VMiehFYgdQP/3Rw0zgi4f5JqlOTJ3CSOmWG
3tqK5F87mvgVJXYKKMSxSH1QNv/AdDOKk9CFkY2n5AQl/JoRzYQZHnLEhJMQBMob
gtidn1kWb6faWPC2nVXP/nCRAOTNFDpTyybvlEd+cR6qAjmdcbwnMTULyv8maocU
ByhkdRNa37++FypsM91oFb2PxYmNmyGZ9AWEh+RZ3c2Cnes87l4LPS45q56YIU3R
saMWdGBKwNhuoeE5ke+MEJhc2/E0Skcm1lulnG/6fXD7mTQuCt987nmcr6/CMhQq
MCMA9g6Mc//wAaDSwgzykvG8t9QPoOzbDn/1PfTHkmMrTQdpefA0S3qt9bHONLnE
CFktkqjXFYEKvcvZkYIM6rS5GEcvM/Py5SRAcmtxp7YiaLl9aahtFJ8i5mb/IYza
KBASnKqqFC4dWx2gspC+VCzottQPlgUcqiAW0s+0QGe1yl1tBmZNBZXr3hbJiqCM
edcnQHP7bUmlRZc69qI/5SKYiqCMn+cJ5+fSB7eIsHaODeD4pIdqa0xdyi21iv2o
UGQYmUgzchn/AKocJgwSxZX4iNZ4OHJOsp/EDyUY+prLCtsnF8I+CGNIkBiRnN4x
NzNmCdpBXFxmetd+ZmA8HRne0Y2/UJAgLTqbCv88/JQCUDdl7oyvvML79pDe0Ss7
r/M4joEwhVX7d1iO+4+O
=KcbB
-----END PGP SIGNATURE-----

--=-PXCvc99EZlNgN6KcBu2J--

