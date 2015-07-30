From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: spi_ks8995: clean up
 ks8995_registers_read/write
Date: Thu, 30 Jul 2015 14:17:00 -0700 (PDT)
Message-ID: <20150730.141700.252577173004269743.davem@davemloft.net>
References: <1438206260-13465-1-git-send-email-vz@mleia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: vz@mleia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304AbbG3VRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 17:17:01 -0400
In-Reply-To: <1438206260-13465-1-git-send-email-vz@mleia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladimir Zapolskiy <vz@mleia.com>
Date: Thu, 30 Jul 2015 00:44:20 +0300

> The change removes redundant sysfs binary file boundary checks,
> since this task is already done on caller side in fs/sysfs/file.c
> 
> Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>

Applied to net-next, thanks.
