From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 1/2] iproute: add support for seg6
 l2encap mode
Date: Mon, 28 Aug 2017 12:32:43 -0700
Message-ID: <20170828123243.22c91803@xeon-e3>
References: <20170828190525.15655-1-david.lebrun@uclouvain.be>
        <20170828190525.15655-2-david.lebrun@uclouvain.be>
        <20170828120724.53904cbf@xeon-e3>
        <99974f81-90e8-c6ff-7068-2beb871cb84d@uclouvain.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/r1G1_0/yjDLUPTWX84cR=Uw"; protocol="application/pgp-signature"
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34405 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdH1Tcq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:32:46 -0400
Received: by mail-pg0-f49.google.com with SMTP id y15so4210036pgc.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:32:46 -0700 (PDT)
In-Reply-To: <99974f81-90e8-c6ff-7068-2beb871cb84d@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/r1G1_0/yjDLUPTWX84cR=Uw
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 28 Aug 2017 20:11:59 +0100
David Lebrun <david.lebrun@uclouvain.be> wrote:

> On 08/28/2017 08:07 PM, Stephen Hemminger wrote:
> > Since these values probably will grow over time, it would make
> > sense to have this a name/value table. =20
>=20
> I wasn't sure if it was worth it for 3 values. I do not foresee a large
> growth either, but I will send a v2 will a table anyway
>=20
> David

Either way, not a big worry.

--Sig_/r1G1_0/yjDLUPTWX84cR=Uw
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEn2/DRbBb5+dmuDyPgKd/YJXN5H4FAlmkb9wACgkQgKd/YJXN
5H77wA//V1KOWFsTXPCBmg3LcgdooYrtvG7ynpeSvwWr5hVGfZwK1Sv330IWp/7y
uK0mfIZAU1rZuh+r/X95YjbNs0+fvtnzsAdehV6bbx1GQC9c6rvPCVLESSGYjHdi
KIqAs6hhEjEEoM/aelal+tmGfCrAz01Yh6qcwUq83VX3XVxW/RO0pXOTQWqyoIBG
acoB0+bwv6bHrODl8Wag3BSilHJD2cyyLBL99hQefsae6KTZAorbSRJi7NoZtTbW
V4i1BgEHL5dkA8+oJqcJNX/GZ/MFk5HbOLcXNFTf4VUbSUYfsQvQpE3Iwj/4+r9v
Qdx6TWgU3t4w92TTVnmqn6uO9uCwPg1IHJ5FXCVYuY1Qt5VdFwgNtjrJ42v3/6PM
JqtcRbax2RdtCusIM0DSLAfQ4HVDx4q7q533wP02H90HVI01D16qz61lQqmWRGlj
d0XIwtqF8r298ImCIYgTYIHs2KG3dRFkY4x3SQZeB/+dSCnhESs2EzJDuLOqNFY0
Ztuwz6YAMmCzUf+8RtLDczVQWbUsswrF31UrS5EIJVZt1+iYEhOYInE5G2ecBwbg
oayw/kWBcnAAJN9UJcglCVDioTea2gt7MV9xLMmXw3pi+qxhIc4rHIlnpIqU4SS4
FIcxF0+dzmSghofx2WRsTKKd3f8LurGVSQ2xBOJ9YrMCGu7jVDY=
=tm4Y
-----END PGP SIGNATURE-----

--Sig_/r1G1_0/yjDLUPTWX84cR=Uw--
