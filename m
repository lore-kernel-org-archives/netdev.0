From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] amd-xgbe: AMD XGBE driver updates
 2016-11-15
Date: Wed, 16 Nov 2016 13:58:01 -0500 (EST)
Message-ID: <20161116.135801.1914248995672210530.davem@davemloft.net>
References: <20161115221055.12403.90574.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, colin.king@canonical.com,
        dan.carpenter@oracle.com
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47556 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751464AbcKPS6D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 13:58:03 -0500
In-Reply-To: <20161115221055.12403.90574.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 15 Nov 2016 16:10:55 -0600

> This patch series addresses some minor issues found in the recently
> accepted patch series for the AMD XGBE driver.
> 
> The following fixes are included in this driver update series:
> 
> - Fix a possibly uninitialized variable in the debugfs support
> - Fix the GPIO pin number constraint check
> 
> This patch series is based on net-next.

Series applied, thanks Tom.
