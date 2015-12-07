From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] PHY: DP83867: Remove looking in parent device
 for OF properties
Date: Sun, 6 Dec 2015 19:51:34 -0800
Message-ID: <56650246.8030903@gmail.com>
References: <1449459538-24105-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:35432 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514AbbLGDvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 22:51:36 -0500
Received: by obbnk6 with SMTP id nk6so107195041obb.2
        for <netdev@vger.kernel.org>; Sun, 06 Dec 2015 19:51:35 -0800 (PST)
In-Reply-To: <1449459538-24105-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/12/2015 19:38, Andrew Lunn a =C3=A9crit :
> Device tree properties for a phy device are expected to be in the phy
> node. The current code for the DP83867 also tries to look in the
> parent node. The devices binding documentation does not mention this,
> no current device tree file makes use of this, and it is not behaviou=
r
> we want. So remove looking in the parent device.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
--=20
=46lorian
