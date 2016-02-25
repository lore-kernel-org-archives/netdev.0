From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 00/15][pull request] 1GbE Intel Wired LAN Driver
 Updates 2016-02-24
Date: Thu, 25 Feb 2016 13:59:11 -0800
Message-ID: <1456437551.2969.6.camel@intel.com>
References: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJ3xEMivnEF=xxvp32_UaE2j5v5x8qeO=5of0y4GZOmAe96Hcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-U1Wk2+3CXl0dIhAjacto"
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>, john.ronciak@intel.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57700 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765AbcBYV7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 16:59:12 -0500
In-Reply-To: <CAJ3xEMivnEF=xxvp32_UaE2j5v5x8qeO=5of0y4GZOmAe96Hcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-U1Wk2+3CXl0dIhAjacto
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-02-25 at 09:45 +0200, Or Gerlitz wrote:
> On Thu, Feb 25, 2016 at 4:14 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > v2: Dropped patches 6-10 in the original series.=C2=A0 Patch 6-7 added
> support
> >=C2=A0=C2=A0=C2=A0=C2=A0 for character device for AVB and based on commu=
nity feedback,
> we do not
> >=C2=A0=C2=A0=C2=A0=C2=A0 want to do this.=C2=A0 Patches 8-10 provided fi=
xes to the
> problematic code
> >=C2=A0=C2=A0=C2=A0=C2=A0 added in patches 6 & 7.=C2=A0 So all of them mu=
st go!
>=20
> Jeff,
>=20
> Did you had special reason not to squash patches 8-10 into 6-7 in the
> 1st place?

Well is all water under the bridge now, but I had thought of just
merging Julia's patches into Gangfeng's original series, the only
reason I did not was that the fixes were not by the original author, so
Julia would have lost the recognition for fixes. =C2=A0Had the the original
series not compiled or was functionally broken, I would have required
Gangfeng to re-spin the original series.
--=-U1Wk2+3CXl0dIhAjacto
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWz3kvAAoJEOVv75VaS+3O6dwP/28rq16esbWe1TYxt2uhgJRa
425vNTVlTtoJUm6w8aG3fFHUt2C0EPi+1y7tRw3YQnj+9wPdh93jRSaRWZ7mWQCV
GpZWOl9d9/PhukstjNFzpFsVHH0P/Bu7wYZ8eiSv1tWhkDc55W8ISVXDrPRQlhAf
2phFtptUTGfl0PJuQVbWdOivAsC3EOF0bACTJbkIw9YLdal8e8Jl+FG6gE7snOwi
8/95GhJXqIQXj5B2qy8IJI7FTK4Fh3uGtoj4iMwUkI0T1ODIK/lhR8RncjbbV4nJ
vmtyKGMPVYj6sFISdWSWgZM+jgXgQh70VGyy24dl/VoqtBelJQk9Xrsr1Dy7PXn+
sY9xGKgkfRbGZeIKtA2OZ6zjA/soFLrY0emnyuFrbJOiyEflMCYsPllvgAG98Wyc
c4RVlM55Ppv69iteC0o3kTNSDX03Ba/gK4H5tAjxd4k6JBGqeoULrXzuvCMg2L2N
nkOc3ZGMalkJRIBMjubHNkWl+PO0TjcF89sLvf/L3MEwpAjMUNbIIjuQdYMJK+LX
1t0qCBP+u9ls5E2HCVVaVeF0w8V1Cwjbd4NC9fWVkS2VGpRBxu253BS55/J5Ictd
mMOyKV8fllcRN+WEoI0WnBkuNdbidX4AD2dPDseFFeM5s1cX0+BTWczlv9rmLLpt
ymsg0ChUCF4XZx0Nf4Rw
=fCJD
-----END PGP SIGNATURE-----

--=-U1Wk2+3CXl0dIhAjacto--
