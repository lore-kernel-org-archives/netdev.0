From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] smsc95xx: set MII_BUSY bit to read/write PHY regs
Date: Fri, 09 Nov 2012 16:08:50 -0500 (EST)
Message-ID: <20121109.160850.901809648224300452.davem@davemloft.net>
References: <1352196533-2674-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755617Ab2KIVIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 16:08:52 -0500
In-Reply-To: <1352196533-2674-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Tue,  6 Nov 2012 10:08:53 +0000

> The device datasheet specifies the BUSY bit must be set when reading
> or writing phy registers.  This patch ensures we do that.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>

Steve please let me know why you only submitted patch #2
of an apparent 2 part series.

If I don't get a response soon I'm just going to toss this
patch instead of letting it simply rot in patchwork.

Thanks.
