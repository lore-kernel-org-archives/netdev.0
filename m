From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 07/28] net: dsa: Remove allocation of driver private
 memory
Date: Wed, 23 Dec 2015 12:39:48 -0800
Message-ID: <567B0694.8050409@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-8-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33155 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932509AbbLWUju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:39:50 -0500
Received: by mail-oi0-f46.google.com with SMTP id y66so129473855oig.0
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:39:50 -0800 (PST)
In-Reply-To: <1450875402-20740-8-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
> The drivers now allocate their own memory for private usage. Remove
> the allocation from the core code.
>=20
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
