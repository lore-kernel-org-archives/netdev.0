From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/6] new pcmcia IDs for hostap - NETGEAR MA701
Date: Tue, 16 May 2006 11:01:27 -0400
Message-ID: <4469E947.908@garzik.org>
References: <200605161621.22459.linux-arm@hrw.one.pl> <4469E3F6.5070302@garzik.org> <200605161648.57356.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jouni Malinen <jkmaline@cc.hut.fi>,
	Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:20352 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751201AbWEPPBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 11:01:34 -0400
To: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
In-Reply-To: <200605161648.57356.linux-arm@hrw.one.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcin Juszkiewicz wrote:
> Dnia wtorek, 16 maja 2006 16:38, Jeff Garzik napisa=B3:
>> Marcin Juszkiewicz wrote:
>>> One more Prism2 card which works with HostAP.
>> Please roll these into a single patch.  There's no need to split it =
up
>> such that there is one ID per patch.
>=20
> Index: netdev-2.6/drivers/net/wireless/hostap/hostap_cs.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- netdev-2.6.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-1=
6 16:47:27.469628352 +0200
> +++ netdev-2.6/drivers/net/wireless/hostap/hostap_cs.c	2006-05-16 16:=
47:48.882373120 +0200

Thanks, but you violated rules #6, #5, and #2 of
http://linux.yyz.us/patch-format.html

Also, make sure to CC John Linville, as he's the one who will actually=20
be applying your patch.

Regards,

	Jeff


