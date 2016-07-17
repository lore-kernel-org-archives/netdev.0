From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: ax88172x: use
 phy_ethtool_{get|set}_link_ksettings
Date: Sat, 16 Jul 2016 21:54:52 -0700 (PDT)
Message-ID: <20160716.215452.415847718104141122.davem@davemloft.net>
References: <1468589136-765-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, colin.king@canonical.com, f.fainelli@gmail.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbcGQEyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 00:54:53 -0400
In-Reply-To: <1468589136-765-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri, 15 Jul 2016 15:25:36 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
