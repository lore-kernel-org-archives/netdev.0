From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Fri, 9 Jun 2017 17:03:40 +0200
Message-ID: <20170609150340.GH20756@lunn.ch>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
 <a60a0b26-62b1-7c9e-e846-215747dddb1f@gmail.com>
 <20170609082541.GC31464@kwain>
 <20170609132624.GC20756@lunn.ch>
 <20170609140922.GD31464@kwain>
 <20170609144936.GF20756@lunn.ch>
 <20170609145630.GE31464@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        jason@lakedaemon.net, gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43404 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751562AbdFIPDv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 11:03:51 -0400
Content-Disposition: inline
In-Reply-To: <20170609145630.GE31464@kwain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There are two busses, one generating c22 transactions and one generating
> c45 transactions. Each bus has its own MDC/MDIO pins.

O.K. That is what i wanted to know. So we want two completely separate
device tree bindings, busses registered with Linux, etc.

Thanks for clarification.

       Andrew
