From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: net: ti: cpsw-phy-sel: RGMII is not working on AM335x
Date: Wed, 11 Jan 2017 16:14:07 +0100
Message-ID: <20170111151407.GW22820@lunn.ch>
References: <1484122463.3777.1.camel@phytec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexandru Gagniuc <alex.g@adaptrum.com>,
        "David S. Miller" <davem@davemloft.net>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org
To: Teresa Remmet <t.remmet@phytec.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55150 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1765162AbdAKPON (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 10:14:13 -0500
Content-Disposition: inline
In-Reply-To: <1484122463.3777.1.camel@phytec.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So I wonder what is correct now? As for me the patch makes RGMII unusable.
> Has anyone an explanation?

Hi Teresa

In your device tree, what phy-mode do you have?

And does your hardware require an RGMII delay in order that it works?

    Andrew
