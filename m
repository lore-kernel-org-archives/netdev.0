From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Not need to set fl6.flowi6_flags as zero
Date: Sat, 28 Sep 2013 15:52:39 -0400 (EDT)
Message-ID: <20130928.155239.1656178261637728049.davem@davemloft.net>
References: <1379919359-3032-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755096Ab3I1Twl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 15:52:41 -0400
In-Reply-To: <1379919359-3032-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon, 23 Sep 2013 14:55:59 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> setting fl6.flowi6_flags as zero after memset is redundant, Remove it.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
