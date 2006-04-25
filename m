From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 25 Apr 2006 13:30:20 +0200
Message-ID: <1145964620.4571.10.camel@localhost>
References: <20060424194006.GB21761@tuxdriver.com>
	 <20060424204044.GC21761@tuxdriver.com>
	 <1145925182.9369.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ODUXhZ6McnVFzrRk/d6L"
Cc: "John W. Linville" <linville@tuxdriver.com>, jeff@garzik.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46535 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751550AbWDYLaf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 07:30:35 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1145925182.9369.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ODUXhZ6McnVFzrRk/d6L
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2006-04-24 at 20:33 -0400, Dan Williams wrote:

> Any way to get the event handling cleanup patch into 2.6.17?  It's
> pretty much a bugfix and bcm43xx is useless with wpa_supplicant and NM
> without the patch...

No, that's not true, the cleanup patch is exactly that, code cleanup :)

Externally, softmac behaves the same without it since your patch and
some other patches I did on top of that have already gone in.

johannes

--=-ODUXhZ6McnVFzrRk/d6L
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARE4ISqVg1VMiehFYAQLZtxAAv3v1QR3ziFa/PWt/3ofomEk6Lp3cYHMF
rSDn+B3Gua/lOlwDzysTjUnCAhsNrTkMREeaIgt+zoDOebbAawVyyRTNVtunWedG
qoQKwOsWc6RYUPAiRYTIW7FnPQX1/o62Lum7uQh69mnqCl+gjS5KiKY4GjzO9ARo
FiJOmmD9FC5tjuhRCEKW3GSL6ryX12iE4FcTUxIIuVfj4ycVCcgrT0szsYTXLMJL
xvrvKowZ49JJLYAWDBg/rlniML0V6bj24TzQXMwe/mCigQP2LFPI1PdLO+bmaDWa
IqcioF+DOREfXSqCb5Fw3U69qIg6GSVIUsVHvg8xtPtNyQKK9goXgEnaj9m9yr2V
kNuTM/nvJcYutpEoIiasKjvCUe28gvbgSNDFsoUBlr6F5ZcrA6Gwfyso9awa+4uA
VyrHrSc6LHQ0QUQhtGyXJC/xmel6Ix2+TW4oSAvwGNrThIqr6vLwH1a78kuWjqNt
r355dPVM3pgmFJEbKMIazrBaL0B5Ti0TL5Xz/RaNNTgFBGbt9qLQcxfTQT5vtXBB
3MkFiXG4KVzQjh60HxuNPDkAQcSwszKUOiZoPAe41SvjT4K5tu0L1cP5uEeaiRJo
0vjsYlw+etMxm6dwZG8IWIU4jb+5zBvXKVZfAER+0cK8nDlNiN/+zy4oA1TYkAcH
EUyRS3dZC4s=
=HXiW
-----END PGP SIGNATURE-----

--=-ODUXhZ6McnVFzrRk/d6L--

