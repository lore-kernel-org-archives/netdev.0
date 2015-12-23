From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 24/28] net: dsa: If a switch fails to probe, defer
 probing
Date: Wed, 23 Dec 2015 12:46:05 -0800
Message-ID: <567B080D.40406@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-25-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:34100 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965408AbbLWUqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:46:06 -0500
Received: by mail-ob0-f176.google.com with SMTP id iw8so172281722obc.1
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:46:06 -0800 (PST)
In-Reply-To: <1450875402-20740-25-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
> Switches are either listed in device tree of platform_data. They
> should exist. If the probe fails, defer the probe, which is the likel=
y
> cause of failure, not broken device tree or platform data.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
