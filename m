From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 5/5] arm/dts: am33xx: Add cpsw and mdio module nodes
 for AM33XX
Date: Tue, 16 Oct 2012 10:51:43 -0700
Message-ID: <20121016175143.GX15569@atomide.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
 <b4d88ef79fb0dec95bb598aaf1f15f0a7344c435.1350327325.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-04-ewr.mailhop.org ([204.13.248.74]:33810 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755124Ab2JPRvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 13:51:45 -0400
Content-Disposition: inline
In-Reply-To: <b4d88ef79fb0dec95bb598aaf1f15f0a7344c435.1350327325.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Richard Cochran <richardcochran@gmail.com> [121015 12:23]:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> 
> Add CPSW and MDIO related device tree data for AM33XX.
> Also enable them into board/evm dts files by providing
> respective phy-id.

These omap specific .dts changes  should be queued by Benoit Cousson,
please cc him and linux-omap.

Regards,

Tony
