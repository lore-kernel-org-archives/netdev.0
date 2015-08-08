From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] dsa: Support multiple MDIO busses
Date: Sat, 08 Aug 2015 10:33:29 -0700
Message-ID: <55C63D69.8070702@gmail.com>
References: <1439046554-9669-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:35064 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992555AbbHHRdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2015 13:33:31 -0400
Received: by obbop1 with SMTP id op1so99148241obb.2
        for <netdev@vger.kernel.org>; Sat, 08 Aug 2015 10:33:31 -0700 (PDT)
In-Reply-To: <1439046554-9669-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/08/15 08:09, Andrew Lunn a =C3=A9crit :
> When using a cluster of switches, some topologies will have an MDIO
> bus per switch, not one for the whole cluster. Allow this to be
> represented in the device tree, by adding an optional mii-bus propert=
y
> at the switch level. The old platform_device method of instantiation
> supports this already, so only the device tree binding needs extendin=
g
> with an additional optional phandle.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
