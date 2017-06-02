From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: mv88e6xxx: 6161 uses global 2 for PHY access
Date: Fri, 02 Jun 2017 17:28:33 -0400
Message-ID: <87lgparse6.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1496438566-30612-1-git-send-email-andrew@lunn.ch> <1496438566-30612-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chris Healy <cphealy@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:49430 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdFBVaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 17:30:39 -0400
In-Reply-To: <1496438566-30612-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> Access to the internal PHYs of the 6161 and 6123 go through global 2
> SMI registers. Fix the ops structure.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
