From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: nullify ipv6_ac_list and ipv6_fl_list when
 creating new socket
Date: Thu, 29 Sep 2011 00:34:18 -0400 (EDT)
Message-ID: <20110929.003418.625954241549573771.davem@davemloft.net>
References: <4E7F1CCA.5000104@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46296 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295Ab1I2Eec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 00:34:32 -0400
In-Reply-To: <4E7F1CCA.5000104@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yan, Zheng" <zheng.z.yan@intel.com>
Date: Sun, 25 Sep 2011 20:21:30 +0800

> ipv6_ac_list and ipv6_fl_list from listening socket are inadvertently
> shared with new socket created for connection.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>

Applied.
