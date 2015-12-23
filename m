From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 12/28] net: dsa: Make dsa,mii-bus optional
Date: Wed, 23 Dec 2015 12:42:25 -0800
Message-ID: <567B0731.4050607@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-13-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:32923 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932509AbbLWUm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:42:27 -0500
Received: by mail-ob0-f170.google.com with SMTP id bx1so55440925obb.0
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:42:27 -0800 (PST)
In-Reply-To: <1450875402-20740-13-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
> When all the switches are devices and register to the DSA framework,
> having a dsa,mii-bus property is not required.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
