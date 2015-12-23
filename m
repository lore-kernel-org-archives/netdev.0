From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 05/28] net: dsa: Pass the dsa device to the switch
 drivers
Date: Wed, 23 Dec 2015 12:36:19 -0800
Message-ID: <567B05C3.3050700@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33205 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965368AbbLWUgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:36:21 -0500
Received: by mail-ob0-f176.google.com with SMTP id bx1so55350562obb.0
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:36:21 -0800 (PST)
In-Reply-To: <1450875402-20740-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
> By passing a device structure to the switch devices, it allows them
> to use devm_* methods for resource management.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
