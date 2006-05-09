From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 3/4] IrDA: smsc-ircc: Minimal hotplug support.
Date: Tue, 09 May 2006 15:26:24 -0700 (PDT)
Message-ID: <20060509.152624.31350732.davem@davemloft.net>
References: <20060508212359.GD20933@irie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, irda-users@lists.sourceforge.net,
	netdev@vger.kernel.org, dbrownell@users.sourceforge.net,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30865
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751244AbWEIW1C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 18:27:02 -0400
To: samuel.ortiz@nokia.com
In-Reply-To: <20060508212359.GD20933@irie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel.ortiz@nokia.com>
Date: Tue, 9 May 2006 00:23:59 +0300

> Minimal PNP hotplug support for the smsc-ircc2 driver.  A modular driver
> will be modprobed via hotplug, but still bypasses driver model probing.
> 
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> Signed-off-by: Samuel Ortiz <samuel.ortiz@nokia.com>

Applied, thanks a lot.
