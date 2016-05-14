From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] drivers: net: xgene: Bug fixes
Date: Fri, 13 May 2016 21:12:26 -0400 (EDT)
Message-ID: <20160513.211226.1164377917890147208.davem@davemloft.net>
References: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, toanle@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753557AbcENBMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 21:12:30 -0400
In-Reply-To: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Fri, 13 May 2016 16:52:56 -0700

> This patch set addresses the following bug fixes that were found during testing.
> 
>   1. IPv4 forward test crash
>     - drivers: net: xgene: fix IPv4 forward crash
> 
>   2. Sharing of irqs
>     - drivers: net: xgene: fix sharing of irqs
> 
>   3. Ununiform latency across queues
>     - drivers: net: xgene: fix ununiform latency across queues
> 
>   4. Fix statistics counters race condition
>     - drivers: net: xgene: fix statistics counters race condition
> 
>   5. Correcting register offset and field lengths
>     - drivers: net: xgene: fix register offset
> 
> v2: Address review comments from v1
> - Defer TSO fix, and reposting all other patches from v1
> 
> v1:
> - Initial version
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

Series applied, thanks.
