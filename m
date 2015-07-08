From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] net: igb: implement high frequency periodic
 output signals
Date: Wed, 08 Jul 2015 16:14:17 -0700
Message-ID: <1436397257.3214.14.camel@intel.com>
References: <1436280102-30310-1-git-send-email-richardcochran@gmail.com>
	 <20150708.161150.1028571714100873421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-R8ARDUDxK8Fly0z+Pz+b"
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	jacob.e.keller@intel.com, matthew.vick@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:53713 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299AbbGHXOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 19:14:20 -0400
In-Reply-To: <20150708.161150.1028571714100873421.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-R8ARDUDxK8Fly0z+Pz+b
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-07-08 at 16:11 -0700, David Miller wrote:
> From: Richard Cochran <richardcochran@gmail.com>
> Date: Tue,  7 Jul 2015 16:41:42 +0200
>=20
> > In addition to interrupt driven target time output events, the i210
> > also has two programmable clock outputs.  These clocks support
> periods
> > between 16 nanoseconds and 140 milliseconds.  This patch implements
> > the periodic output function using the clock outputs when possible,
> > falling back to the target time for longer periods.
> >=20
> > Signed-off-by: Richard Cochran <richardcochran@gmail.com>
>=20
> I assume I will get this via the Intel folks in a future pull request.

Correct, I will be adding it to my queue.

Richard- FYI for the future, could you at least CC
intel-wired-lan@lists.osuosl.org on the Intel wired LAN patches.  It
helps me keep track of patches against our drivers. Thanks!

--=-R8ARDUDxK8Fly0z+Pz+b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVna7JAAoJEOVv75VaS+3O87kP/R3WFqZVxQSxMUbZo4n1sECT
IMsz49zzxjrbZvCd07Dtjn+jOm4EVbuTCUSpXE1orPaMvatrDw1FXO55Mzs8nMZk
Is6FaI0O877IAb2N4yvIA67gkzbf3qZJGaC5KXq5DLdpojn06paqEW8lm0D1pbH5
ZxzhGmQ1VFyezuNotzg4ateehArL/yx/mhK4CJuZPDMDWseYYAP95cSF/V4lDU3w
3cO5A2jKGIoLbk2RDzEiVnSeNE2B+so+LMoVmBax9oKSeOInFdIWg1O4NMDnukoI
qCVjy8pqsUwEv8tKtJZrhOqUPqr+m2sFMYQQjRHWfA7KubFW2waCMB7xCKtxZ/Rc
iWhsjBXI/WV9bOy7oj+moycYr7fwUgWUSzWpRhrkg8uBygQ/yeyqbgDH93R1z/fL
yVhga1SiXPIBLdwJ9w18lmUU8OSQgcwUTKiThppsOiNrvVuSkpCdR9/So9nE8OpM
Gz8Jusj/nhSzP38qLU/UmT0c7/tLUEbclxcyeqPTZtDx/QeAal8UWm2Wrke+s5tM
ubtHoyCDTb+HS5iLuDY0IQd463RMRoKQAh1XYh4aNXeqiDmO7L9n7v7RP6OiM33X
TIkXr032L/+0rDsjHVKGvdBWahCoSL/tIXkUaydhkAsQHxliJvJoNkcnCZ9YvB68
BUIGLvssdVq4TNo67bce
=9Pgy
-----END PGP SIGNATURE-----

--=-R8ARDUDxK8Fly0z+Pz+b--
