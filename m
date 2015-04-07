From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netdevice.h: remove iflink description
Date: Tue, 07 Apr 2015 17:31:00 -0400 (EDT)
Message-ID: <20150407.173100.1424862282323275485.davem@davemloft.net>
References: <1428401416-27626-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753713AbbDGVbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 17:31:01 -0400
In-Reply-To: <1428401416-27626-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  7 Apr 2015 12:10:16 +0200

> Also move 'group' description to match the order of the net_device structure.
> 
> Fixes: 7a66bbc96ce9 ("net: remove iflink field from struct net_device")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied to net-next, thanks.
