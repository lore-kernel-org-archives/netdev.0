From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/3] amd-xgbe: AMD XGBE driver updates
 2015-04-09
Date: Thu, 09 Apr 2015 17:36:20 -0400 (EDT)
Message-ID: <20150409.173620.1763287386950592271.davem@davemloft.net>
References: <20150409171145.22188.37025.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754144AbbDIVgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 17:36:21 -0400
In-Reply-To: <20150409171145.22188.37025.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 9 Apr 2015 12:11:45 -0500

> The following series of patches includes functional updates and changes
> to the driver.
> 
> - Allow ethtool rx-frames coalescing to be changed while the device is up
> - Consolidate initialization routine into the init function
> - Add support for the TX watchdog timeout
> 
> This patch series is based on net-next.

Series applied, thanks Tom.
