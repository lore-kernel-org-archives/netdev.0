From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 5/9] net: dsa: Allow DSA and CPU ports to have
 a phy-mode property
Date: Sun, 23 Aug 2015 11:44:33 -0700
Message-ID: <55DA1491.2070900@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch> <1440323220-20438-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:34601 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbbHWSof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 14:44:35 -0400
Received: by oiey141 with SMTP id y141so68232587oie.1
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 11:44:34 -0700 (PDT)
In-Reply-To: <1440323220-20438-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/23/15 02:46, Andrew Lunn a =C3=A9crit :
> It can be useful for DSA and CPU ports to have a phy-mode property, i=
n
> particular to specify RGMII delays. Parse the property and set it in
> the fixed-link phydev.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
