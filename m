From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 0/3] amd-xgbe: AMD XGBE driver fixes 2017-02-28
Date: Thu, 02 Mar 2017 13:02:42 -0800 (PST)
Message-ID: <20170302.130242.1337867667174030884.davem@davemloft.net>
References: <20170228210242.32166.30038.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751102AbdCBVCn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 16:02:43 -0500
In-Reply-To: <20170228210242.32166.30038.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 28 Feb 2017 15:02:42 -0600

> This patch series addresses some issues in the AMD XGBE driver.
> 
> The following fixes are included in this driver update series:
> 
> - Stop the PHY before disabling and releasing device interrupts so that
>   MDIO requests issued by the device can be properly handled
> - Set the MDIO communication mode on device startup, not just device
>   probe
> - Do not overwrite SFP settings when mod_absent is detected
> 
> This patch series is based on net.

Series applied, thanks.
