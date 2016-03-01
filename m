From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
 using a device tree blob V5
Date: Tue, 01 Mar 2016 15:55:09 -0800
Message-ID: <1456876509.3039.10.camel@intel.com>
References: <56C5A6BC.6030708@gmail.com>
	 <309B89C4C689E141A5FF6A0C5FB2118B81EA731A@ORSMSX101.amr.corp.intel.com>
	 <DC20A3D2-95E2-420B-911D-C6AC02338227@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4UefHq2zuZjnnzZAFL1t"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: John Holland <jotihojr@gmail.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59149 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755564AbcCAXzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 18:55:31 -0500
In-Reply-To: <DC20A3D2-95E2-420B-911D-C6AC02338227@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4UefHq2zuZjnnzZAFL1t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-03-01 at 07:56 +0100, John Holland wrote:
> On Mar 1, 2016, at 03:52, Brown, Aaron F <aaron.f.brown@intel.com>
> wrote:
>=20
> > This throws a few checkpatch warnings, but I won't withhold my
> tested by for these:
> >=C2=A0
> > total: 0 errors, 2 warnings, 0 checks, 21 lines checked
> >=C2=A0
> > Your patch has style problems, please review.
> >=C2=A0
> > NOTE: If any of the errors are false positives, please report
> >=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 them to the maintainer, see CHECKPATCH in=
 MAINTAINERS.
> > u1463:[0]/usr/src/kernels/next-queue>
>=20
> Thanks for testing...
>=20
> Do you require me to reformat the patch text? And won't that break
> the link?

No, that checkpatch.pl warning on the link you provided is fine,
although I will clean up your signed-off-by when I go to push it
upstream. :-)
--=-4UefHq2zuZjnnzZAFL1t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW1ivdAAoJEOVv75VaS+3OgeAP/REwOpYL41MVG0KgkLGrUc3W
MKhqUkrAGXvYgr0yHMekpReeiHVEFcFIy2jbdZkH3W1LKwD71+6EmWhC53pukYIf
PS0Xv3TX0oqDrRjD2Q+ch3lXAxrAfDOaFUD0oS/QxHrZpsP7kNSeyRsAC4KDC1e4
1bNSIuC5j18f3h+Lxg2OuO07Gud/j0qWn+EawATRdPpOUdjnZ36LV7LzL+YsbHC3
P+7J6Y8IjwJW0cQEtVR5p+mTmin00KuYoIz7veHeFKCQOWkpgLjzwgeNk3fvYGOu
Fa0Fa/bnRBW5K9Fd0K3hqV84zf4fH7yRH1qPfaj3HUwwZ8udS7nwrhn2sT8wDpgS
WSl7QxX4ZTOMyDrA2noU8Zp3ttii/MeFzmP3xu+qS+wT32UaAe0cZtAvs2fX1gh6
dEeXDEU3pLnNrFRJ6Gg7DQzmwxNzOn0p21pf2qgwjXQ5KgL6qm3pA2japZTtC65k
T1ItiAKzpj8sP1c0Oi7cP+uIctaCyYrWmsTOj3F7lwShlsIzsdicxFhr15sQIKPx
ObtFC7qjIs9wPNxAQNuKHs6n3Bec8EHakQ/Q/uNAQ1b5hGZ7AQBFCwsA0X87rTqo
T9oOTEISsfus1iDSLZbak/24tyADl2KukQcwa4hITkC8hKyL/PZmttBCi8P9yE5W
u+aV+sjEUfiHzv5O/GLr
=QSVT
-----END PGP SIGNATURE-----

--=-4UefHq2zuZjnnzZAFL1t--
