From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] amd-xgbe: AMD XGBE driver updates 2016-11-14
Date: Tue, 15 Nov 2016 22:13:15 -0500 (EST)
Message-ID: <20161115.221315.2085419689375024221.davem@davemloft.net>
References: <20161114222827.25160.24791.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, julia.lawall@lip6.fr,
        christophe.jaillet@wanadoo.fr
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35492 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935096AbcKPDNR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:13:17 -0500
In-Reply-To: <20161114222827.25160.24791.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Mon, 14 Nov 2016 16:28:27 -0600

> This patch series addresses some minor issues found in the recently
> accepted patch series for the AMD XGBE driver.
> 
> The following fixes are included in this driver update series:
> 
> - Fix how a mask is applied to a Clause 37 register value
> - Fix some coccinelle identified warnings
> 
> This patch series is based on net-next.

Series applied.
