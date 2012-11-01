From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: PTP get_ts_info missing software support
Date: Thu, 01 Nov 2012 11:33:11 -0400 (EDT)
Message-ID: <20121101.113311.1707046769031188674.davem@davemloft.net>
References: <1351758654-9718-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacob.e.keller@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598Ab2KAPdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 11:33:17 -0400
In-Reply-To: <1351758654-9718-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  1 Nov 2012 01:30:54 -0700

> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> This patch corrects the ethtool get_ts_info functon which did not state that
> software timestamping was supported, even though it is.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> CC: Stable <stable@vger.kernel.org> [3.5]
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
