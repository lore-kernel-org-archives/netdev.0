From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] amd-xgbe: AMD XGBE driver update
 2014-08-01
Date: Sat, 02 Aug 2014 19:31:00 -0700 (PDT)
Message-ID: <20140802.193100.251109735631225265.davem@davemloft.net>
References: <20140801165623.20602.457.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51023 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbaHCCbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 22:31:04 -0400
In-Reply-To: <20140801165623.20602.457.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 1 Aug 2014 11:56:23 -0500

> The following series of patches includes minor fixes/updates to the
> driver.
> 
> - Remove some uses of spinlock around ethtool/phylib areas
> - Update Rx/Tx ready check logic
> 
> This patch series is based on net-next.

Series applied, thanks Tom.
