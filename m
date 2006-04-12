From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH] softmac: (v2) send WEXT assoc/disassoc events to
	userspace
Date: Thu, 13 Apr 2006 01:56:48 +0200
Message-ID: <1144886208.4187.26.camel@localhost>
References: <1141928917.26954.7.camel@localhost.localdomain>
	 <1141935893.28038.2.camel@localhost.localdomain>
	 <441091B8.4010103@lwfinger.net>
	 <1141936896.28038.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/IwJKH1LYbsWSjrgGFhn"
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	softmac-dev@sipsolutions.net, David Woodhouse <dwmw2@redhat.com>,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([213.151.39.204]:25730 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932340AbWDLX6t
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 19:58:49 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1141936896.28038.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/IwJKH1LYbsWSjrgGFhn
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-03-09 at 15:41 -0500, Dan Williams wrote:

> Can you grab a debug log from wpa_supplicant?  Run wpa_supplicant with
> the args "-ddd", and _don't_ run it as a daemon.  Mail the output to me
> if you don't want it to go to everyone on the cc list (might include
> SSIDs and such).  That should allow us to figure out exactly where
> wpa_supplicant and/or the driver are having issues.

Did this ever happen? I'm currently trying to collect all the pending
patches

johannes

--=-/IwJKH1LYbsWSjrgGFhn
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARD2TvaVg1VMiehFYAQKvtA/9HrrsQQIX8iaHir74e/Huva0ufsQTMDDe
76Uwa+YGjbsEpq00gPTW9oAw4LDmWnHGEDvIC8KXNdfEXtnIVsno+YaKc1phHdPW
43dMVA39uy13J1z+cMNu2Fd7JzHF7ePAnLnIfLfu3LX1rQmEdOTOB6ZnDCuHGyrz
KdaTUhmHaP9Id4T1EtsrHrPxIEIWQ7+dzlt/f/09iTElalhfGSs8PmrY9Ke/4Ejv
cELRty3v4kfkTBwpyn2WB/bZvuUoILA06loAid0vhcunIijxHKwZ4fA90Agf7u8K
rOpjHW4BWsGg9gjUECLmcNdZGCZqE4kI72ZQ6MhfiaysX9egSDFVHYHm9crJjMpp
b+Pgr62ln8/g/DeZpbmZJr+TU3PUyquKBJhBXiCWm0i/gq+dRdSflcwfb6j9uKhq
2wuoo0Y6dzpce+/jzX1PtRohNDXbDYL86S4bUL9sRvvwo3alBh/TrkZeXdwcrE6h
/4+q0hC73p0uomcxhokM1kM1CwBJiReKV2N7L4lE31r8y6RhOsLPMf768apo03Gn
Wq37p1rxE2hk0ltRQ0F79A71fOtzc5Lf93e/MbgzItl3wtQeSfP4FxcT8I/Y31RV
VtUjheKccFv8cwtb8s53vCDKGLZH++dUJ97VE4RxczJ9UVVUyJnjopPAC1BeeLxF
LD037VK8FEc=
=jaEE
-----END PGP SIGNATURE-----

--=-/IwJKH1LYbsWSjrgGFhn--

