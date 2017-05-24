From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 4/5] net: dsa: mv88e6xxx: mv88e6390X SERDES support
Date: Wed, 24 May 2017 10:59:23 -0400
Message-ID: <87r2zeti5w.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1495573486-31827-1-git-send-email-andrew@lunn.ch> <1495573486-31827-5-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47984 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940404AbdEXPBX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 11:01:23 -0400
In-Reply-To: <1495573486-31827-5-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The mv88e6390X family has 8 SERDES lanes. These can be used for 2
> 10Gbps ports, ports 9 or 10. If these ports are used at slower speeds,
> the SERDES lanes become available for other ports for 1000Base-X.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
