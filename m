From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: properly report internal PHYs
 through sysfs
Date: Fri, 29 Aug 2014 20:18:14 -0700 (PDT)
Message-ID: <20140829.201814.895484489060154239.davem@davemloft.net>
References: <1409165073-26983-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbaH3DSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 23:18:15 -0400
In-Reply-To: <1409165073-26983-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 27 Aug 2014 11:44:33 -0700

> Internal PHYs may not have a valid PHY interface defined, which will
> show up in sysfs as "". Add an explicit check of internal PHYs to report
> their interface correctly.
> 
> Fixes: 3d055d8d1c24 ("net: phy: expose PHY device interface mode")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
