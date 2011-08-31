From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net] e1000: Fix driver to be used on PA RISC C8000 workstations
Date: Tue, 30 Aug 2011 17:48:36 -0700
Message-ID: <1314751717.2204.55.camel@jtkirshe-mobl>
References: <1314749966-9960-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110830.203903.2196937547187204637.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-GG7po4byhs7xldT3kgvR"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"stable@kernel.org" <stable@kernel.org>,
	"gmsoft@tuxicoman.be" <gmsoft@tuxicoman.be>,
	"eike-kernel@sf-tec.de" <eike-kernel@sf-tec.de>,
	"mattst88@gmail.com" <mattst88@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8264 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754208Ab1HaAsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 20:48:37 -0400
In-Reply-To: <20110830.203903.2196937547187204637.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GG7po4byhs7xldT3kgvR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-08-30 at 17:39 -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Tue, 30 Aug 2011 17:19:26 -0700
>=20
> > +#ifdef __hppa__
>=20
> Please use CONFIG_PARISC

Ok, I will put together a v2 of the patch with your suggested change.

--=-GG7po4byhs7xldT3kgvR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOXYTkAAoJECTsCADr/EWUCOAH/jMR7NA5Yw49bOnTSxmt0yfh
NtdN0OHBg4iRRvHhtDQufAdjlXwLXAQ34iWhbyF0a18AywV9xxFXBUrxTJpIGOvY
8zE9KQ4n4q89TE4JdoLk/zG7pxQO+gi12+2Vug7ZGWo/egVnoHKhjPePMjD8adRy
/sEZzcLly+NNazAxFJoAcH3X4SYNu6QV1yPoZIHESJGAW2lBCPpCwPQagbPZEkMn
HmYnkF1+leOk5LF6GNvzJW/PLz9VAvse1mGb4/MwX0hvmrrkXdvblkCFKWU1sm3Z
w2UXiJzws8VIHWc+kbBN+Ig0QxFAEko85HuCxLOxm3WpffDef9qFPSTRIE0bt3Y=
=IYmL
-----END PGP SIGNATURE-----

--=-GG7po4byhs7xldT3kgvR--
