From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next] net: dsa: mv88e6xxx: Implement Clause 45 access to SMI devices
Date: Sat, 04 Feb 2017 14:49:25 -0500
Message-ID: <87mve1ka7u.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1486235544-11640-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45024 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750944AbdBDTuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 14:50:03 -0500
In-Reply-To: <1486235544-11640-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The mv88e6390 MDIO bus controllers can support for clause 45 accesses.
> The internal SERDES interfaces need this, and it is likely external
> 10GHz PHYs will be clause 45.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
