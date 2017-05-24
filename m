From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 2/5] net: dsa: mv88e6xxx: Refactor mv88e6352 SERDES code into an op
Date: Wed, 24 May 2017 11:03:22 -0400
Message-ID: <87o9uifgat.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1495573486-31827-1-git-send-email-andrew@lunn.ch> <1495573486-31827-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48364 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759784AbdEXPFX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 11:05:23 -0400
In-Reply-To: <1495573486-31827-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The mv88e6390 family has a different SERDES implementation. Refactor
> the mv88e6352 code into an ops function, so we can later add the
> mv88e6390 code.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
