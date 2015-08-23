From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 7/9] dsa: mv88e6xxx: Don't poll forced interfaces
 for state changes
Date: Sun, 23 Aug 2015 11:41:35 -0700
Message-ID: <55DA13DF.1010009@gmail.com>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch> <1440323220-20438-8-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:34936 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbbHWSlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 14:41:37 -0400
Received: by oiew67 with SMTP id w67so68423385oie.2
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 11:41:36 -0700 (PDT)
In-Reply-To: <1440323220-20438-8-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/23/15 02:46, Andrew Lunn a =C3=A9crit :
> When polling for link status, don't consider ports which have a force=
d
> link. Such ports don't monitor their phy or may not even have a phy.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
