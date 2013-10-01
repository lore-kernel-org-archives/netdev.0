From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: phy: marvell.c: removed checkpatch.pl
 warnings
Date: Mon, 30 Sep 2013 22:15:57 -0700 (PDT)
Message-ID: <20130930.221557.1329073627639782500.davem@davemloft.net>
References: <1380514004-8701-1-git-send-email-avi.kp.137@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com, lars@metafoo.de, RHoover@digilentinc.com,
	netdev@vger.kernel.org
To: avi.kp.137@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966Ab3JAFI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 01:08:58 -0400
In-Reply-To: <1380514004-8701-1-git-send-email-avi.kp.137@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Avinash kumar <avi.kp.137@gmail.com>
Date: Mon, 30 Sep 2013 09:36:44 +0530

> removes following warnings-
> drivers/net/phy/marvell.c:37: WARNING: Use #include <linux/io.h> instead of <asm/io.h>
> drivers/net/phy/marvell.c:39: WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>
> 
> Signed-off-by: Avinash Kumar <avi.kp.137@gmail.com>

Applied, thanks.
