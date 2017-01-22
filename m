From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 0/2] amd-xgbe: AMD XGBE driver fixes 2017-01-20
Date: Sun, 22 Jan 2017 16:54:27 -0500 (EST)
Message-ID: <20170122.165427.1209521597327918697.davem@davemloft.net>
References: <20170120181352.2321.63733.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56112 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAVVyl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 16:54:41 -0500
In-Reply-To: <20170120181352.2321.63733.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Fri, 20 Jan 2017 12:13:52 -0600

> This patch series addresses some issues in the AMD XGBE driver.
> 
> The following fixes are included in this driver update series:
> 
> - Add a fix for a version of the hardware that uses different register
>   offset values for a device with the same PCI device ID
> - Add support to check the return code from the xgbe_init() function
> 
> This patch series is based on net.

Series applied.
