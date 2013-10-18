From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next  11/14] i40e: reorder block declarations in debugfs
Date: Fri, 18 Oct 2013 07:34:52 -0700
Message-ID: <1382106892.2034.7.camel@jtkirshe-mobl>
References: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1382102598-11343-12-git-send-email-jeffrey.t.kirsher@intel.com>
	 <52614206.7050404@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-i/tszdQRHcmtzwIsWRP6"
Cc: a@vger.kernel.org, davem@davemloft.net,
	Shannon Nelson <shannon.nelson@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13147 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750811Ab3JROey (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 10:34:54 -0400
In-Reply-To: <52614206.7050404@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-i/tszdQRHcmtzwIsWRP6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-10-18 at 18:13 +0400, Sergei Shtylyov wrote:
> On 18-10-2013 17:23, Jeff Kirsher wrote:
>=20
> > From: Shannon Nelson <shannon.nelson@intel.com>
>=20
> > This is a cleanup of the arguments declared at the beginning
> > of each function.
>=20
>     I hope you meant "local variables" because "arguments" are the
> values=20
> passed to a function.

Yes, he meant local variables.

--=-i/tszdQRHcmtzwIsWRP6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSYUcMAAoJEOVv75VaS+3OGRgQAJeoP3Z/n/SrY42yBN2QEBN2
zpj7/ZEJWCq6Op0O4FNRkhpYD88mJcPxOSaOwJ363auWiRvZuMTwohEw2TiqbMMV
IF1VxQOoNxpVj+ZSF5eCgwY3dnQB8FqR8Qe8s21hwHS3uyzecfVtafHo7uutkCbU
Xm5cvNcbodGnv9P+JQK+KM4re2KxXRbe8LYzqPgZ5cXgB2hCkrKWEPIm27kmChkg
OvsZ0YxvDMUtbqUc3yK6wWdF/763G+9wOVMRUsd0ie4uT6+FmODG0d47H/smpMQ7
+FRlw/kWO44xwtUfXW2JsABMnn/yMqspKxgA7zM0MJ3dmx3/sitZB3BDVS7aF5Yv
JT3FUH6Z+k7qLtM3Lsx5zzNgLHOB/ZwuyiAo7wdATAFWzswcSWFB+pmDGOSQP8G5
GCtxC2eOivDwi9lFGuMDuxk6XaOzIlg78mi1M4ry8Xse7Qg67Aw71LPSdaAEKebs
FplF9oEAGS4/Ot4CbWkkyZWwt5x19/1uPG+8xH/HOvUtEP4iYwu1Ok6qNQDaHT0y
e/z15Eq2BC9GFklB61qgL2wqRCZRkuxlj1eZOjJb77hud/EGEn9jAVXIQ1zD2vOw
07Juhf/PnRYoK/X3pNrTg++bNejcDvHra9anPE6OehEZtrDOJz4m0wlhnMQKJNrt
EQqhs3kA7nq34/Cvdnl3
=K+SJ
-----END PGP SIGNATURE-----

--=-i/tszdQRHcmtzwIsWRP6--
