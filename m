From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v5 1/2] net: dsa: mv88e6xxx: Don't forbid MDIO I/Os for PHY addr >= num_of_ports
Date: Thu, 19 Jan 2017 20:54:39 -0500
Message-ID: <87d1fi1oo0.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com> <20170119214934.27442-2-gregory.clement@free-electrons.com> <871svylmvb.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <20170120000645.GA31483@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40832 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754013AbdATBzJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 20:55:09 -0500
In-Reply-To: <20170120000645.GA31483@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> Isn't there an hardware table used to map the PHY addresses on such chip?
>
> The 6390 has something like this. But if we can avoid it, lets keep it
> KISS.

I definitely agree. I was just curious about this new chip.

Thanks,

        Vivien
