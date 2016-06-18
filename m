From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: ethernet: et131x: use
 phy_ethtool_{get|set}_link_ksettings
Date: Fri, 17 Jun 2016 22:31:24 -0700 (PDT)
Message-ID: <20160617.223124.810246110715420747.davem@davemloft.net>
References: <1466199135-13459-1-git-send-email-tremyfr@gmail.com>
	<1466199135-13459-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.einon@gmail.com, andrew@lunn.ch, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, f.fainelli@gmail.com, fw@strlen.de,
	wuninsu@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbcFRFbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 01:31:25 -0400
In-Reply-To: <1466199135-13459-2-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri, 17 Jun 2016 23:32:15 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
