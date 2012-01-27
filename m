From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net V4 0/2] igb: ptp hardware clock
Date: Fri, 27 Jan 2012 02:15:27 -0800
Message-ID: <1327659327.2729.55.camel@jtkirshe-mobl>
References: <cover.1327161325.git.richardcochran@gmail.com>
	 <1327638293.2729.43.camel@jtkirshe-mobl>
	 <20120127101119.GA6690@netboy.at.omicron.at>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3gnlQlna3Ud21LUuEMJ9"
Cc: "Brown, Aaron F" <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4927 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752710Ab2A0KP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jan 2012 05:15:29 -0500
In-Reply-To: <20120127101119.GA6690@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3gnlQlna3Ud21LUuEMJ9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-01-27 at 11:11 +0100, Richard Cochran wrote:
> On Thu, Jan 26, 2012 at 08:24:53PM -0800, Jeff Kirsher wrote:
> > Richard-
> >=20
> > Did you compile test?  Why I ask is our validation team is getting the
> > following errors when trying to compile in PTP support:
>=20
> I did compile and also tested the driver.
>=20
> What .config are you using? What kernel version?
>=20
> Thanks,
> Richard

I will have Aaron post his .config's that he tried.  I know that he
tried multiple configs with no success.  As far as kernel version, he
was using the latest net-next tree from David Miller.

--=-3gnlQlna3Ud21LUuEMJ9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPInk/AAoJEOVv75VaS+3Orp4P/jfJx8u6PF8dC2+ScuV9m9Pc
fQ0LzMD7+I43oxcUvNrzyidcak6KhhiKrE+3FSBcNnswh9WW1xecFHR+86wnaUeN
A9v8KD1GQexQzSgYTMdDczNiDJMcBHb6xdDuocmzP8ipkNYpchvTES/lc7HBFRe9
TKp7EVQtfs8w2nKsebSvRclp1fXIv7JuAugdY5fhZNcRMokibzrJ3cLDWmsRFJA5
XwMOEK7c3+YtSZoPoLYJe4eGaOE8bt3pq0QFTUD2OX0K/gHCsYILgYNO9z9L1MeJ
Qoes16x22S3AIkBqMelrGZhSLbIZ0ENxlL4ZfM9w6WHMCaiyoM9NtUe4VAIFNEwN
YQO0HDgV67ohv0KnrwBkcZLhkO3p+uoOXbriYaBf9MScBbE+xuc0CCCduhmtOfaf
XpPN4uGtdopPiXf/oB55lIEbEms/659baZE1U5kVpSGZ/oo8UcjQ7i0L4lWUZjQr
L7fUohd24ETW+og3BtbXIwlPkrP3XcapgCHkOOCpiLJ74G3jsCGRmedWa6VvTbxf
kl/KNbU49YJ9ydYn+te4TvYNKhBaLpJjK0eKs+MGAeEOBU+D5Ovy2dhgFNmbi6y9
0hY6TyU9hJYSmZ8RAM/XbuSz9L+wxXz9TXd6SyelfNVZAMx8qz2eeUNvJfv/rUx8
ln48ATHSXNDO+V7WlIIi
=3LLV
-----END PGP SIGNATURE-----

--=-3gnlQlna3Ud21LUuEMJ9--
