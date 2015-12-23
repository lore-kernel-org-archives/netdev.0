From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 08/28] net: dsa: Keep the mii bus and address in the
 private structure
Date: Wed, 23 Dec 2015 12:40:52 -0800
Message-ID: <567B06D4.5060706@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-9-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:33237 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932509AbbLWUkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:40:53 -0500
Received: by mail-ob0-f174.google.com with SMTP id bx1so55417756obb.0
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:40:53 -0800 (PST)
In-Reply-To: <1450875402-20740-9-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
> Rather than looking up the mii bus and address every time, do it once
> and setup, and keep it in the private structure.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
