From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dt-bindings: net: remove reference to fixed link
 support
Date: Fri, 03 Feb 2017 15:59:38 -0500 (EST)
Message-ID: <20170203.155938.1981764313840579677.davem@davemloft.net>
References: <1486054064-31093-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, robh+dt@kernel.org,
        ijc+devicetree@hellion.org.uk, pawel.moll@arm.com,
        mark.rutland@arm.com, galak@codeaurora.org, netdev@vger.kernel.org,
        linux@arm.linux.org.uk, mw@semihalf.com, jason@lakedaemon.net,
        andrew@lunn.ch, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        hannah@marvell.com, yehuday@marvell.com,
        linux-arm-kernel@lists.infradead.org
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52286 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752271AbdBCU7l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 15:59:41 -0500
In-Reply-To: <1486054064-31093-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Thu,  2 Feb 2017 17:47:44 +0100

> Contrary to what the Device Tree binding indicates, the binding for the
> PPv2 network device currently doesn't provide any fixed link
> functionality. This commit adjusts the Device Tree binding documentation
> accordingly.
> 
> Reported-by: Russell King - ARM Linux <linux@armlinux.org.uk>
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

What tree is this intended to go into?  Mine?
