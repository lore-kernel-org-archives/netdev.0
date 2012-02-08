From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH 1/5] send-crc: Add framework to allow sending packets
 with customized CRC.
Date: Wed, 08 Feb 2012 00:02:52 -0800
Message-ID: <4F322C2C.1010708@gmail.com>
References: <1328644182-7872-1-git-send-email-greearb@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig5717D6E6B72612A83F8FCF7A"
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6679 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754146Ab2BHICx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Feb 2012 03:02:53 -0500
In-Reply-To: <1328644182-7872-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5717D6E6B72612A83F8FCF7A
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/07/2012 11:49 AM, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
>
> This is useful for testing RX handling of frames with bad
> CRCs.
>
> Requires driver support to actually put the packet on the
> wire properly.
>
> Signed-off-by: Ben Greear <greearb@candelatech.com>
Ben-

I tried to apply this series to Dave's net-next tree and I stopped after
the first two patches did not apply cleanly.

What tree did you use to generate this patch series?

Cheers,
Jeff


--------------enig5717D6E6B72612A83F8FCF7A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJPMiwsAAoJEOVv75VaS+3Of7gP/R9TWsHRnC/j/JbwpkMFYlW2
JtD/dzmeIzN6i6q9qekejhlEduuRZb98ZE2woUQCcZ+Msv0TSrVzalPXd2gfXQ5n
sz+SRsBiMnvnFpmTEBt4nX7YJlKH3AwOjiJBrglHCPJUq+F3FqF8W4iPDjAl9BmM
G92AoKaZLtOSKaDXhO+GbYd2xkzhH0UHskkh+hPDIn3F40rCKOgZ8ZYjX+w3ObV0
/hBQ6CauY2hIj9baXyvBPU95Vl9AyL8zKxnccoXhBMB7LVbrSyah0VtpB21lBS+0
9bXKeTg8FU6IZWp29lVkDpKfvzUKKTbOEcSyPc45kgeG7wOKX7sZhJPZ+PsFIRy0
oEBNjpTZadTZoVQdEf8pU9nX1Dm4OjgWxetK7OSfNun95xjT35o4g1BYh40i1LSL
2hOqmg7QlVjWP5wywHGOW5HPeWz6NKDnpfclhEN5N6JdcX1ZZc7fFQtvxSlNYMit
JAaP4EmmyYWFeHL2crIK2xmGFJRWwcnyU4qcp+xLO3zFbX9Agm4ssjYewVLqTTOr
djksruVrStEMG4w7r0giKvluztSOvwnz36OZYHwvO+ElWZYLe/ga1kMOK+HeDO+O
ZtYRCP5E0fHBNRn2FBDv1KoOX7ov/10atuD19d5C54GUp7TAFbH90V5sMjq6o8CN
uKt02dHVDXeH2wzf6DRT
=D6g1
-----END PGP SIGNATURE-----

--------------enig5717D6E6B72612A83F8FCF7A--
