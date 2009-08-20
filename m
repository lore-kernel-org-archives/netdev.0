From: Stephen Neuendorffer <stephen.neuendorffer@xilinx.com>
Subject: RE: [PATCH] [V3] net: add Xilinx emac lite device driver
Date: Thu, 20 Aug 2009 10:45:03 -0700
Message-ID: <20090820174607.05A1AC10058@mail141-va3.bigfish.com>
References: <20090820094956.02DFC45004F@mail96-dub.bigfish.com> <20090820160356.F1A03340054@mail79-sin.bigfish.com> <fa686aa40908201044y17acb4c1lacf09fafc2647fa4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John Linn" <linnj@xilinx.com>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>, <davem@davemloft.net>,
	<jgarzik@pobox.com>, "John Linn" <linnj@xilinx.com>,
	"Sadanand Mutyala" <sadanan@xilinx.com>,
	"John Williams" <john.williams@petalogix.com>,
	"Michal Simek" <michal.simek@petalogix.com>
To: "Grant Likely" <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:54245
	"EHLO VA3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754944AbZHTRqI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 13:46:08 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <fa686aa40908201044y17acb4c1lacf09fafc2647fa4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry... you're right... brain fart on my part.. :)

Steve

> -----Original Message-----
> From: glikely@secretlab.ca [mailto:glikely@secretlab.ca] On Behalf Of=
 Grant Likely
> Sent: Thursday, August 20, 2009 10:45 AM
> To: Stephen Neuendorffer
> Cc: John Linn; netdev@vger.kernel.org; linuxppc-dev@ozlabs.org; davem=
@davemloft.net;
> jgarzik@pobox.com; John Linn; Sadanand Mutyala; John Williams; Michal=
 Simek
> Subject: Re: [PATCH] [V3] net: add Xilinx emac lite device driver
>=20
> On Thu, Aug 20, 2009 at 10:02 AM, Stephen
> Neuendorffer<stephen.neuendorffer@xilinx.com> wrote:
> >
> > John,
> >
> > I just got a chance to browse this... =A0Do you want to put in the
> > stripped device names?
> >
> > .compatible =3D "xlnx,xps-ethernetlite-2", etc...
>=20
> We've covered this territory before.  Compatible values need to be
> exact for the IP cores.  No wildcards. No abbreviations or stripping.
> Newer cores can claim compatibility with older when appropriate.
>=20
> g.
>=20
> --
> Grant Likely, B.Sc., P.Eng.
> Secret Lab Technologies Ltd.


This email and any attachments are intended for the sole use of the nam=
ed recipient(s) and contain(s) confidential information that may be pro=
prietary, privileged or copyrighted under applicable law. If you are no=
t the intended recipient, do not read, copy, or forward this email mess=
age or any attachments. Delete this email message and any attachments i=
mmediately.


