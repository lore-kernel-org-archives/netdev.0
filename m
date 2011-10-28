From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix error propagation in ip6_ufo_append_data()
Date: Fri, 28 Oct 2011 00:26:11 -0400 (EDT)
Message-ID: <20111028.002611.1226969977769353003.davem@davemloft.net>
References: <4EAA2E74.2000703@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab1J1E0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 00:26:15 -0400
In-Reply-To: <4EAA2E74.2000703@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yan, Zheng" <zheng.z.yan@intel.com>
Date: Fri, 28 Oct 2011 12:24:20 +0800

> We should return errcode from sock_alloc_send_skb()
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>

Applied, thanks!
