From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] [net-next] net: qcom/emac:
Date: Sun, 29 Jan 2017 19:07:29 -0500 (EST)
Message-ID: <20170129.190729.1384810104230916960.davem@davemloft.net>
References: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42626 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdA3AP4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 19:15:56 -0500
In-Reply-To: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Fri, 27 Jan 2017 16:43:42 -0600

> Although not related, these patches affect the same files, so they should
> be applied in order.
> 
> The first patch cleans up logging of when the the phy driver is attached.
> 
> The second patch always configures the SGMII to use autonegotiation mode.
> 
> The third patch removes a redundant call to emac_mac_start().
> 
> The fourth patch removes some extraneous non-functioning WOL code.
> 
> The fifth patch adds an error handler for the SGMII block.

Series applied, thanks.
