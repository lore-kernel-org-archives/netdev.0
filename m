From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: rfkill rewrite bug
Date: Tue, 14 Apr 2009 22:46:08 +0200
Message-ID: <1239741968.4205.1.camel@johannes.local>
References: <49DCA88E.6060400@tuffmail.co.uk>
	 (sfid-20090408_153722_059382_FB44D658) <1239204090.16477.1.camel@johannes.local>
	 <49DCDD2E.80705@tuffmail.co.uk>  <49E38BBC.5010708@tuffmail.co.uk>
	 (sfid-20090413_205524_915082_56358705)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-qqQk0AIqcKsVk98imhZW"
Cc: netdev@vger.kernel.org
To: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:47139 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316AbZDNUql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 16:46:41 -0400
In-Reply-To: <49E38BBC.5010708@tuffmail.co.uk> (sfid-20090413_205524_915082_56358705)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qqQk0AIqcKsVk98imhZW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-04-13 at 20:00 +0100, Alan Jenkins wrote:

> I tried the latest patch (#19) from your website, it didn't work so well=20
> :-).

I think I fixed that now, I allowed using set_sw_state before register
and that didn't go too well with the LED system w/o any checks.

johannes

--=-qqQk0AIqcKsVk98imhZW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJ5PYOAAoJEKVg1VMiehFYHKEP/jJDcV0H2diuiOh9E9UAGY6f
Fx6OqftDVxd5gOyB3FwIZehJxD79zPtd1hBTbhXxNankhHjU6jUDy4tqMc5JdxD2
3n4fRRPs0iIe7+s57rt2koly+KICZmI5FwD/KY3XrCpxldmqEusirKLiu+Yq40Sg
0vPH+l3O7tTpRxclJNykU10+EhvjOnrmjmZq7dyOjcM42+Fofi9dGmZ7IL0lIaOG
uPD5v9tCeJBnd8w0ZRb21b2sKCMggShC4z0vgT3oLS3R/OhmLbgCR3UsqUV0O9pf
yV9lKC5D4xL8RUoLbBUT4ARU1MtPRpe8imS+OzdFWlR/VcPO/7RrLuF6bjCGnpX0
4zo517CjkzQsMjspW2iYVtS2wXW3FvIvPwNHkfuorV+fgfjKd7v040n78e1PXYKL
Q9zDPxiJhzBsYspWmfQsHWOgGyM55pMyy2rFs5ugzPNeX83EXwmRcUS1cpOvkFYP
LxN79q7Cc5GtbSteDAb9a6dGiIpWdJDr6nyEvW4OR9+T3agC53Oc7el8DTZjjdyu
YjVs7Wburc33/bFSna4oUsIS7nSdbKrtx/f/9qRfXWa5SeZWKMB+C5O4yOgMxfxz
PzMqv1JlcREN/MQoUIm3BKiLv0Pf0iZSAcnZ8PHXKA8m3PLA6rVjxNFQEJjHh4CJ
URKCOoZ0PEWRqUAEM6sn
=uvR6
-----END PGP SIGNATURE-----

--=-qqQk0AIqcKsVk98imhZW--

