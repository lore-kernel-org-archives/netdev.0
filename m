From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 00/10] Low-level Ethernet debugging features.
Date: Thu, 09 Feb 2012 21:52:07 -0800
Message-ID: <1328853127.2761.45.camel@jtkirshe-mobl>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
	 <4F349DB0.1010903@gmail.com> <4F34AE62.6070409@candelatech.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-beuDTJX93ib7IiOfcd+c"
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63497 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932308Ab2BJFwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 00:52:09 -0500
In-Reply-To: <4F34AE62.6070409@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-beuDTJX93ib7IiOfcd+c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-02-09 at 21:42 -0800, Ben Greear wrote:
> On 02/09/2012 08:31 PM, Jeff Kirsher wrote:
>=20
> > Thanks Ben!
> >
> > I have applied the series of 10 patches to my queue.  I would like to
> > have our validation team validate the e100, e1000 and e1000e patches
> > (and in-directly the net patches).
>=20
> Just in case you can generate errored frames other than ones with just
> bad FCS, I'm curious to know if rx-all logic works with them.
>=20
> I was thinking I might could get at least some NICs to generate Runt fram=
es
> by sending small pkts and disabling frame padding, but haven't looked int=
o
> it too hard yet.
>=20
> Thanks,
> Ben
>=20

Thanks for the info Ben!  I or Aaron will let you know what we come up
with.

--=-beuDTJX93ib7IiOfcd+c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPNLCHAAoJEOVv75VaS+3OFzIP/1etcAgQEmcfAzYXf9NbsuZj
aRvJTzhv/KTJTHthePluc66ZDjn4wY9d6EEp+PPTll3DQm4z9inXwCWnCaP6YUxz
PCP6oHz7DhI1dEv1+MHvEo1mz+ntjDcEfljY4BIwp/GfboFBFRD9ygHVWJ0oVb7U
BpKDp5zJ1zPFZ0A2+eKMLT/QX0sBf7wkm99ve7NacaITQaNnGh5oRNiZQ8o3drBI
CZ2v+bqJpkaKWuGesEl12T8Lj609MaeiXngviQmC4FJy5m8vEKGIEWGeeMi3xyAQ
u7/kYHJhK2fn+UdZH96Df7BOTakxuHHNTiR3qGyoxsSJhYrLPh9YWVq2/hwc2Wdd
z6WumbZB5Lf6xJ6Lh4YxLo15MqPdBZ5STBH5oCYqYb3UkPowNX25kHw/TQjcNMTl
XIdzQISHGDcQ1sWFt3NcoWO5AgibSpDjwd3PS8TF2/2gg0bbujYErRdPHGR5CaVE
oHR0LOEW+Vv66TB5I+gNOJ6tczwfksQ0WgjOaDmD4qVL2B5JAEDJWXnqFFSvg1iw
UzS5xt1YdjruQtUStUlhEIlb2hSrdGjPnR3omOgswAk3nrp2eLh5D2JThUhEb/gu
kvN6W7FhD+oBq9D7B0SWEdc23xq0bPuJSInDbNp/Y4Vmng6k3MAMmNwORN9QVcyj
V2q8rSPq47zVVkfroA2B
=VU+k
-----END PGP SIGNATURE-----

--=-beuDTJX93ib7IiOfcd+c--
