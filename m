From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 00/10] amd-xgbe: AMD XGBE driver updates
 2016-11-03
Date: Fri, 04 Nov 2016 14:52:36 -0400 (EDT)
Message-ID: <20161104.145236.2079189350150895706.davem@davemloft.net>
References: <20161103181727.7383.34446.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41924 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935039AbcKDSwi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 14:52:38 -0400
In-Reply-To: <20161103181727.7383.34446.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Thu, 3 Nov 2016 13:17:28 -0500

> This patch series is targeted at preparing the driver for a new PCI version
> of the hardware.  After this series is applied, a follow-on series will
> introduce the support for the PCI version of the hardware.
> 
> The following updates and fixes are included in this driver update series:
> 
> - Fix formatting of PCS debug register dump
> - Prepare for priority-based FIFO allocation
> - Implement priority-based FIFO allocation
> - Prepare for working with more than one type of PCS/PHY
> - Prepare for the introduction of clause 37 auto-negotiation
> - Add support for clause 37 auto-negotiation
> - Prepare for supporting a new PCS register access method
> - Add support for 64-bit management counter registers
> - Update DMA channel status determination
> - Prepare for supporting PCI devices in addition to platform devices
> 
> This patch series is based on net-next.

Series applied, thanks Tom.
