From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] smsc95xx: set MII_BUSY bit to read/write PHY regs
Date: Wed, 07 Nov 2012 15:39:02 -0500 (EST)
Message-ID: <20121107.153902.2217073223869338435.davem@davemloft.net>
References: <1352196533-2674-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40949 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117Ab2KGUjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 15:39:03 -0500
In-Reply-To: <1352196533-2674-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@shawell.net>
Date: Tue,  6 Nov 2012 10:08:53 +0000

> The device datasheet specifies the BUSY bit must be set when reading
> or writing phy registers.  This patch ensures we do that.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>

Steve, what's the story here?  Where is patch #1?
