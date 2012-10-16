From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 2/5] ARM: OMAP3+: hwmod: Add AM33XX HWMOD data for
 davinci_mdio
Date: Tue, 16 Oct 2012 10:50:45 -0700
Message-ID: <20121016175045.GW15569@atomide.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
 <c048044c10b5712e25d190a0ae1dfee3155f81f7.1350327325.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-04-ewr.mailhop.org ([204.13.248.74]:31937 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755016Ab2JPRur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 13:50:47 -0400
Content-Disposition: inline
In-Reply-To: <c048044c10b5712e25d190a0ae1dfee3155f81f7.1350327325.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Richard Cochran <richardcochran@gmail.com> [121015 12:23]:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> 
> This patch adds minimal hwmod support for davinci mdio driver. This patch
> requires rework on parent child relation between cpsw and davinci mdio
> hwmod data to support runtime PM.

Looks like Paul Walmsley may have missed this one, maybe please resend
with him and linux-omap cc:d.

Regards,

Tony
