From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/phy: tune get_phy_c45_ids to support more c45
 phy
Date: Sun, 28 Jun 2015 17:06:12 -0700 (PDT)
Message-ID: <20150628.170612.452335507208677988.davem@davemloft.net>
References: <1435312732-24890-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shengzhou.Liu@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045AbbF2AGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 20:06:13 -0400
In-Reply-To: <1435312732-24890-1-git-send-email-Shengzhou.Liu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Date: Fri, 26 Jun 2015 17:58:52 +0800

> As some C45 10G PHYs(e.g. Cortina CS4315/CS4340 PHY) have
> zero Devices In package, current driver can't get correct
> devices_in_package value by non-zero Devices In package.
> so let's probe more with zero Devices In package to support
> more C45 PHYs.
> 
> Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>

Applied.
