From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] amd-xgbe: AMD XGBE driver update
 2014-08-05
Date: Tue, 05 Aug 2014 16:47:23 -0700 (PDT)
Message-ID: <20140805.164723.1980380162725348147.davem@davemloft.net>
References: <20140805183032.32561.85828.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbaHEXrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:47:24 -0400
In-Reply-To: <20140805183032.32561.85828.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 5 Aug 2014 13:30:32 -0500

> The following series of patches includes fixes/updates to the driver.
> 
> - Use dma_set_mask_and_coherent to set the DMA mask
> - Move the phy connect/disconnect logic to allow for module unloading
> 
> This patch series is based on net-next.
> 
> Changes in V2:
> - Check the return value of the dma_set_mask_and_coherent call

Series applied, thanks.
