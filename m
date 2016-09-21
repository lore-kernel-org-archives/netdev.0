From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv3 net-next 1/2] net: dsa: mv88e6xxx: Add helper for accessing port registers
Date: Tue, 20 Sep 2016 20:43:04 -0400
Message-ID: <87d1jy3wx3.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1474414832-1638-1-git-send-email-andrew@lunn.ch> <1474414832-1638-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48253 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753383AbcIUAnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 20:43:09 -0400
In-Reply-To: <1474414832-1638-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> There is a device coming soon which places its port registers
> somewhere different to all other Marvell switches supported so far.
> Add helper functions for reading/writing port registers, making it
> easier to handle this new device.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks!

        Vivien
