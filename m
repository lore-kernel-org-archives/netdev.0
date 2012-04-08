From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH V2 net-next 1/1] e100: enable transmit time stamping.
Date: Sat, 07 Apr 2012 23:34:25 -0700
Message-ID: <1333866865.2635.0.camel@jtkirshe-mobl>
References: <cover.1333802620.git.richardcochran@gmail.com>
	 <d9af1ff17599cb3e3fa6e1163a417727c3fa09fc.1333802621.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KJtl9l1Jb28z92YPEYPb"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:33949 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751887Ab2DHGeh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Apr 2012 02:34:37 -0400
In-Reply-To: <d9af1ff17599cb3e3fa6e1163a417727c3fa09fc.1333802621.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KJtl9l1Jb28z92YPEYPb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-04-07 at 14:49 +0200, Richard Cochran wrote:
> This patch enables software (and phy device) transmit time stamping.
> Tested on an old PIII laptop with built in NIC.
>=20
> Cc: Alex Duyck <alexander.h.duyck@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/net/ethernet/intel/e100.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)=20

Thanks Richard, I will add this to my queue.

--=-KJtl9l1Jb28z92YPEYPb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPgTFxAAoJEOVv75VaS+3O1lMP/izJKyX4x/vRPVgEsw4NSZ4o
xXc+UlLBTM61+EKMiCAYAdfq0PiHKw42KCqxaZNDVMipRVZyJZ1JxVRxcCGIIJPr
owVh12LlAUfHP8NPa3dRrRq6V+C+Y50SI+HoTo9TIGqjSCf7TwNcPdz1L3rN2Xcf
4XdYu/5rLsS6ejwOgWUM8weHgYbLNYPL/SIKH392vN4bIMsKaIm9oveux5C4aOYG
Bmho3G4PWmel6fWdDsGC5x0k6r6kJEZdK4tmpeS+Fgk9alUEXM4k0UwlyJhn/am7
Ob9k9gzoMvnHwnJHdtbFKEVPQ5quYqT8aItdA+qvNRHXyorUNe4Gs8WEyAq3kH70
sjUk2+nG32PA+zpX0+IZ92RVLl1ICxoUsXczQmCOBJsxqJ6woEj65MDKEfQMgcsH
YY8JH6WuFk8ZW5ag1PRgOpa8kW7XWRb67KAVlwGs3v0S5XrAqhG3xhYxG5c/v61Z
14155+IO1wXBSwIdsEMHdGVJTLUoM4ttk8gDi4Zl7TlWarXX0jeCYWJ8c2+vsjLh
Tz3j3CpDKNXp95TuvZWOSKnMQe83x539eCIpd7RBp8oagbJygHpOdJXRe4AVW89p
ipcfWv08Eyr1mPnJmi356CXzzxbFMmna1HrJ05Snw7oFwuHG44Eu1ujCqMofXbv7
bP4Kdb8/dowIJ4IQvC7w
=CR7m
-----END PGP SIGNATURE-----

--=-KJtl9l1Jb28z92YPEYPb--
