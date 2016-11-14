From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 01/11] net: dsa: mv88e6xxx: Take switch out of reset before probe
Date: Mon, 14 Nov 2016 12:23:55 +1100
Message-ID: <87mvh297mc.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1478832823-31471-1-git-send-email-andrew@lunn.ch> <1478832823-31471-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39136 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbcKNBYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 20:24:07 -0500
In-Reply-To: <1478832823-31471-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The switch needs to be taken out of reset before we can read its ID
> register on the MDIO bus.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
