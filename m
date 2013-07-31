From: Felipe Balbi <balbi@ti.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new
 CPSW IP version
Date: Wed, 31 Jul 2013 23:07:56 +0300
Message-ID: <20130731200756.GA3737@radagast>
References: <1375272746-24446-1-git-send-email-mugunthanvnm@ti.com>
 <20130731144957.GC4904@netboy>
 <20130731152827.GB25618@radagast>
 <20130731163845.GB4234@netboy>
 <20130731184525.GA629@radagast>
 <20130731192229.GB8027@netboy>
 <20130731194332.GA900@radagast>
 <20130731194523.GB900@radagast>
 <20130731200428.GD8027@netboy>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5mCyUwZo2JvN/JJP"
Cc: Felipe Balbi <balbi@ti.com>, Mugunthan V N <mugunthanvnm@ti.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-omap@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:51980 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756796Ab3GaUIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 16:08:10 -0400
Content-Disposition: inline
In-Reply-To: <20130731200428.GD8027@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--5mCyUwZo2JvN/JJP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Jul 31, 2013 at 10:04:28PM +0200, Richard Cochran wrote:
> On Wed, Jul 31, 2013 at 10:45:23PM +0300, Felipe Balbi wrote:
> >=20
> > one more thing, why do you consider a new revision to be an error ?
>=20
> Okay, so why don't you go and remove the version checking code
> altogether?

if you need to treak certain aspects of the IP differently, you need the
revision check, don't be so childish.

what I'm saying is that we can give new IP revision a chance to work if
they have no programming model differences (except for, perhaps, new
features and different erratas).

On dwc3 (drivers/usb/dwc3) we support every single revision of the IP.
We only have revision checks to enable (or not) known silicon erratas.

--=20
balbi

--5mCyUwZo2JvN/JJP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJR+W6cAAoJEIaOsuA1yqREYZ4P/06sC5DftazUHj6J9jCrseL0
WcVe0UwYAaT63CwDRlAb9gCWj6a0izpUhsHCGl63F2iAuxou+S8tXfpZg7KyPmAI
gHTMm1tW06r6rBTJf32x3dowJmDLUjUM8zXqZX/VY9hDQhdOi8D27cPcRfjSCGjp
dFIPry8rN/No3UicSmlJM23wwtzIZKR16xsx5uWua+x9p42GlL8R2j/Ju627ZavX
LhNKxqHqsP/DS65d+jRnNjpFiPjVobxjFreljzGqyIHcmGc6BNBwR8XDoCIDZ03+
vtaqXVVHr+SgiePmsBzc+uwcz+JuSsvZUyMAUM/2Dc4ZlpK8+i15uzFaFHKIWeUq
kbf85xyXAXRtP7AEMe6YP/aiuQ3DvDWsrFFccs9zsgw6BnL0SKTSGiPvir6UtMlS
QVhZb6jnGFuyjF6jbr6585Cb00esnpbaKG/OHi0beLZuv7Kjnokqaty3Dt/MCMeY
0SojG9RuVJv7LvroGYUL/h8X27Ue2MGUYcaoVjat1ezo0LBt+J4zgV9mZh+DutoH
OjIo2+/BWhquf/3Hkxu77xJwHI6yJ1ehOihDBILCqaLkwcXV0DobnsdkBztqzVSD
Qmln6pk1EON4JPjulUXU5avBxk0GlPJjPWc1Y2gTAEbXjpHogNPw7shdejMRvWkC
Ar23ksDWVqgM8zhqUwGv
=/+ZH
-----END PGP SIGNATURE-----

--5mCyUwZo2JvN/JJP--
