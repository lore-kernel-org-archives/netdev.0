From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/11] tg3: 5719, VLAN, and EEE bugfixes
Date: Wed, 26 Jan 2011 07:14:37 +0100
Message-ID: <1296022477.2633.16.camel@edumazet-laptop>
References: <1296007137-23146-1-git-send-email-mcarlson@broadcom.com>
	 <20110125.193859.193720518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43230 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab1AZGOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 01:14:44 -0500
Received: by wyb28 with SMTP id 28so601420wyb.19
        for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 22:14:43 -0800 (PST)
In-Reply-To: <20110125.193859.193720518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 25 janvier 2011 =C3=A0 19:38 -0800, David Miller a =C3=A9crit =
:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Tue, 25 Jan 2011 17:58:46 -0800
>=20
> > This patchset implements bugfixes for the 5719, the VLAN code and
> > enhances EEE support.
>=20
> All applied to net-next-2.6, thanks.
>=20
> In particular, thanks for taking care of the vlan conversion.
> --

I tested the vlan patch on my machine, and it solves the problem I had
with linux-2.6

I believe this particular patch should be net-2.6 material, not
net-next-2.6

(There is a small rejected hunk)

Thanks !


