From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Refactor remaining port setup
Date: Sat, 04 Feb 2017 16:10:27 -0500
Message-ID: <87o9yhoe64.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1486235728-11775-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47702 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751417AbdBDVLE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 16:11:04 -0500
In-Reply-To: <1486235728-11775-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> Move the remaining port configuration code which varies per device
> into port.c, using ops were necessary. This makes
> mv88e6xxx_6185_family() and mv88e6xxx_6095_family() unused, so remove
> them.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
