From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 3/8] net: dsa: mv88e6xxx: Fix ATU age timer for MV88E6390
Date: Fri, 20 Jan 2017 19:10:44 -0500
Message-ID: <8760l9ff23.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch> <1484955062-26718-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:57372 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752110AbdAUALN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:11:13 -0500
In-Reply-To: <1484955062-26718-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The MV88E6390 family uses a different ATU age timer coefficient.
> Fix the the info structures.

Redundant "the" here. Otherwise good catch, the minimum age time is 3.75
seconds.

> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
