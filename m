From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 56/71] macb: Move the Atmel driver
Date: Wed, 03 Aug 2011 02:03:35 -0700
Message-ID: <1312362216.2294.139.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-57-git-send-email-jeffrey.t.kirsher@intel.com>
	 <4E36BCEF.8080703@atmel.com> <1312351168.2294.92.camel@jtkirshe-mobl>
	 <20110803084719.GA2607@pulham.picochip.com> <4E390BCD.4010609@atmel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-y4TaiNC4njoE1tVB6dGv"
Cc: Jamie Iles <jamie@jamieiles.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57330 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594Ab1HCJDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 05:03:36 -0400
In-Reply-To: <4E390BCD.4010609@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-y4TaiNC4njoE1tVB6dGv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-08-03 at 01:50 -0700, Nicolas Ferre wrote:
> On 08/03/2011 09:47 AM, Jamie Iles wrote:
> > On Tue, Aug 02, 2011 at 10:59:28PM -0700, Jeff Kirsher wrote:
> >> On Mon, 2011-08-01 at 07:49 -0700, Nicolas Ferre wrote:
> >>> On 07/31/2011 04:27 AM, Jeff Kirsher wrote:
> >>>> Move the Atmel driver into drivers/net/ethernet/cadence/ and
> >>>> make the necessary Kconfig and Makefile changes.
> >>>>
> >>>> CC: Nicolas Ferre<nicolas.ferre@atmel.com>
> >>>
> >>> You can add my:
> >>> Acked-by: Nicolas Ferre<nicolas.ferre@atmel.com>
> >>>
> >>>> CC: Jamie Iles<jamie@jamieiles.com>
> >>>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> >>
> >> Nicolas/Jamie-
> >>
> >> I have a v3 series of patches coming out here imminently, and I have
> >> tweaked the Kconfig just a bit based on feedback from others.  Since t=
he
> >> "tweak" made sense for all the Kconfig, I applied it across the board.
> >> Here is the new Kconfig:
> > [...]
> >> If these changes are fine, I can add your ACK's.
> >
> > It all reads fine to me though I wonder if we should substitute Atmel
> > for Cadence.  Perhaps this should be a separate patch though that makes
> > it a little clearer in the drivers too.

Not that I am trying to get out of the additional cleanup, but I vote
for a separate patch after we go through the push of this series of
patches. :)

>=20
> Yes, that is true.
>=20
> > Anyhow, for now I'm happy as it is, so:
> >
> > Acked-by: Jamie Iles<jamie@jamieiles.com>
>=20
> Yes, you can add my:
>=20
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks, I will add your ACK's.

--=-y4TaiNC4njoE1tVB6dGv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOOQ7nAAoJECTsCADr/EWUjqIH/jt2OAajCFAVTyYcQFInAu+l
+HKhVE69WEiul3hEE07FhoqHt9MTKmOCoSe2zOv7ML/UlXkTKRfy2SNyqdKxlbq+
PBcdMltqpE/Lru6rFvq+DNNRxYvzb/4vB/qy+7kHx91y1XyvjwoHWqqDMaZGXQuQ
NujuAZAtEcevM76w6/mM7ih5aln6QdrTYnoRoUvJMGHBpCiEriL+2r/0wnvRc3BU
BQ6dMnAXN88nfnr7nesdcZsL2UP0p29Jz/UFGsdEiPMQt/iOsbD6mZBZv1FGPsrp
I+0s/kbRNQa1KTeD5cR0ZQQKMP4u9zhm+y/O9vRwSt0BH8GgXtqZtgJ7Tprq0DQ=
=6r8U
-----END PGP SIGNATURE-----

--=-y4TaiNC4njoE1tVB6dGv--

