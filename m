From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 8/8] net: dsa: mv88e6xxx: Fix typ0 when configuring 2.5Gbps
Date: Fri, 20 Jan 2017 19:53:12 -0500
Message-ID: <87vat9z11j.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch> <1484955062-26718-9-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58726 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752543AbdAUAxr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:53:47 -0500
In-Reply-To: <1484955062-26718-9-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> In order to enable 2.5Gbps mode, we need the base speed of 10G, plus
> the Alt bit setting. Fix a typ0 that used 1Gb base speed.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
