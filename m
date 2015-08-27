From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] drivers: net: xgene: Add TSO support
Date: Thu, 27 Aug 2015 13:51:56 -0700 (PDT)
Message-ID: <20150827.135156.661392666355549469.davem@davemloft.net>
References: <1440614886-23566-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbbH0Uv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 16:51:59 -0400
In-Reply-To: <1440614886-23566-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Wed, 26 Aug 2015 11:48:04 -0700

> Adding TSO support for 10GbE
> 
> iperf Tx data rate without TSO: 3.42 Gbps
>                       with TSO: 9.41 Gbps
> 
> v2: Address review comments from v1
>     - skb_linearize() if headers doesn't fit in 3 hardware buffers
> 
> v1:
> * Initial version
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

Series applied, thanks.
