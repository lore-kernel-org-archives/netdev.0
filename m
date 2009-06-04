From: =?UTF-8?B?UmljaGFyZCBSwprDtmpmb3Jz?=
	<richard.rojfors.ext@mocean-labs.com>
Subject: Re: [PATCH v2] netdev: Added KS8842 driver
Date: Thu, 04 Jun 2009 15:34:51 +0200
Message-ID: <4A27CD7B.6070501@mocean-labs.com>
References: <4A2646F5.6050304@mocean-labs.com> <20090603224147.GB24847@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av8-2-sn3.vrr.skanova.net ([81.228.9.184]:54831 "EHLO
	av8-2-sn3.vrr.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753405AbZFDOCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 10:02:09 -0400
In-Reply-To: <20090603224147.GB24847@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancois Romieu wrote:
> Richard R?=C3=B6jfors <richard.rojfors.ext@mocean-labs.com> :
> [...]
>> Index: linux-2.6.30-rc7/drivers/net/ks8842.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- linux-2.6.30-rc7/drivers/net/ks8842.c	(revision 0)
>> +++ linux-2.6.30-rc7/drivers/net/ks8842.c	(revision 872)
> [...]
>> +struct ks8842_adapter {
>> +	u8 __iomem	*hw_addr;
>=20
> void __iomem *hw_addr;
>=20
> (nit)

Thanks for the feedback, I will post an updated patch.

--Richard
