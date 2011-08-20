From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Linux Kernel | Intel Driver Bug - please update
Date: Sat, 20 Aug 2011 14:51:52 -0700
Message-ID: <1313877113.2128.189.camel@jtkirshe-mobl>
References: <0BE7A0BD7DFE4537AA0C03E333326E52@NOTENIKO>
	 <1311547638.2835.72.camel@jtkirshe-mobl>
	 <504DB0A1B3544F7F8719EF324951BBA7@NOTENIKO>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-7X/iDmJMEr4pMfvssM+y"
Cc: "kristoffer@gaisler.com" <kristoffer@gaisler.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Nicol=E1s?= Sigal | LocalHost Soluciones
	 Innovadoras <nicolas.sigal@localhost.net.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:22996 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754169Ab1HTVvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Aug 2011 17:51:53 -0400
In-Reply-To: <504DB0A1B3544F7F8719EF324951BBA7@NOTENIKO>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7X/iDmJMEr4pMfvssM+y
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-08-20 at 13:35 -0700, Nicol=C3=A1s Sigal | LocalHost Solucione=
s
Innovadoras wrote:
> Please Jeff, we need the update as soon as possible, we still having cras=
hes=20
> of eth because the driver..
>=20
> Best regards;
>=20

The patches have been pushed and accepted.  Are you using Linus's latest
3.1 tree?

>=20
> ----- Original Message -----=20
> From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
> To: "Nicol=C3=A1s Sigal | LocalHost Soluciones Innovadoras"=20
> <nicolas.sigal@localhost.net.ar>
> Cc: <kristoffer@gaisler.com>; "Brandeburg, Jesse"=20
> <jesse.brandeburg@intel.com>; "Allan, Bruce W" <bruce.w.allan@intel.com>;=
=20
> "Ronciak, John" <john.ronciak@intel.com>; <support@localhost.net.ar>;=20
> "netdev" <netdev@vger.kernel.org>
> Sent: Sunday, July 24, 2011 7:47 PM
> Subject: Re: Linux Kernel | Intel Driver Bug - please update
>=20
> On Sun, 2011-07-24 at 13:28 -0700, Nicol=C3=A1s Sigal | LocalHost Solucio=
nes
> Innovadoras wrote:
> > Please, can you update the e1000e driver of the kernel to v1.4.4?
> >
> > http://downloadcenter.intel.com/Detail_Desc.aspx?agr=3DY&ProdId=3D3299&=
DwnldID=3D15817&ProductFamily=3DComponentes+Ethernet&ProductLine=3DControla=
dores+Ethernet&ProductProduct=3DControlador+Intel%C2%AE+82579+Gigabit+Ether=
net&DownloadType=3DControladoresspa
> >
> > This version have an important bug fixed:
> > * 82579: Fix for Tx Hang on FTS ME Platform
> >
> > And we have this problem in all of our servers with this NIC and ME
> > on.
> >
> > Debug:
> >
> > Jul 24 14:23:27 [kernel] e1000e 0000:00:19.0: eth0: Detected Hardware
> > Unit Hang:
> > Jul 24 14:23:27 [kernel]   TDH                  <0>
> > Jul 24 14:23:27 [kernel]   TDT                  <16>
> > Jul 24 14:23:27 [kernel]   next_to_use          <16>
> > Jul 24 14:23:27 [kernel]   next_to_clean        <0>
> > Jul 24 14:23:27 [kernel] buffer_info[next_to_clean]:
> > Jul 24 14:23:27 [kernel]   time_stamp           <10282156f>
> > Jul 24 14:23:27 [kernel]   next_to_watch        <0>
> > Jul 24 14:23:27 [kernel]   jiffies              <102821aed>
> > Jul 24 14:23:27 [kernel]   next_to_watch.status <0>
> > Jul 24 14:23:27 [kernel] MAC Status             <80143>
> > Jul 24 14:23:27 [kernel] PHY Status             <796d>
> > Jul 24 14:23:27 [kernel] PHY 1000BASE-T Status  <0>
> > Jul 24 14:23:27 [kernel] PHY Extended Status    <3000>
> > Jul 24 14:23:27 [kernel] PCI Status             <10>
> > Jul 24 14:23:28 [kernel] e1000e 0000:00:19.0: eth0: Reset adapter
> > Jul 24 14:23:30 [kernel] e1000e: eth0 NIC Link is Up 100 Mbps Full
> > Duplex, Flow Control: Rx/Tx
> > Jul 24 14:23:30 [kernel] e1000e 0000:00:19.0: eth0: 10/100 speed:
> > disabling TSO
> >
>=20
>=20
> [removed ixgbe/igb Intel maintainers, and Linus from the email thread]
> Added a more appropriate mailing list (netdev)
>=20
> We currently have the kernel patches in review and testing to update the
> e1000e driver to v1.4.4.  I should be able to push some, if not all of
> the changes upstream later this week.
>=20



--=-7X/iDmJMEr4pMfvssM+y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOUCx4AAoJECTsCADr/EWUh9kH/RQPnfL43hXM/Jk3vN1gCerJ
wle4rzkTPJIbA1dx1u5GcixMfggK/+nPcrd3bopniDC0jPpHAsAp3tYbK45AOzd8
trgs4FSeAsRG0I3BfCtVHWEG9nxr8c2JeTRbxRftZAUhXGtO3BAhFXPL9TtovSPD
gDPDCvmN+5WkqHIQ8gYxGDAetLYrzzef4ePjAxirAwFVRMOoVSV9gZOErwl/mZMT
0OOyQs3tCPApZtyDcF6E4iPFaXqRHoKoMqRCWoYURyFEkonlcdtgunyzWSMfrdp7
kXqW+XFji6S3Fw1+KepyrCJDcgANriBI1iSuFDM6+c5TfCK3Ngx4vJU8s/qfcxA=
=Y9/0
-----END PGP SIGNATURE-----

--=-7X/iDmJMEr4pMfvssM+y--

