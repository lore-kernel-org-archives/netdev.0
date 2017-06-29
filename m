From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 00/14] amd-xgbe: AMD XGBE driver updates
 2016-06-28
Date: Thu, 29 Jun 2017 15:16:36 -0400 (EDT)
Message-ID: <20170629.151636.347258154691410175.davem@davemloft.net>
References: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44714 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbdF2TQl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 15:16:41 -0400
In-Reply-To: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 28 Jun 2017 13:41:23 -0500

> The following updates and fixes are included in this driver update series:
> 
> - Simplify mailbox interface code
> - Fix SFP supported and advertising settings
> - Fix PTP initialization register usage
> - Insure there is timestamp skb present before using it
> - Add a timeout to timestamp register updates
> - Handle return code from software reset function
> - Some fixes for handling 2.5Gbps rates
> - Limit I2C error messages
> - Fix non-DMA interrupt handling through tasklet usage
> - Add NUMA affinity support for memory allocations
> - Add NUMA affinity support for interrupts
> - Prepare for more fine-grained cache coherency controls
> - Simplify setting the DMA burst length programming
> - Performance improvements
> 
> This patch series is based on net-next.

Series applied, thanks Tom.
