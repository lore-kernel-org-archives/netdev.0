From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "cxgb4: Don't assume LSO only uses SGL
 path in t4_eth_xmit()"
Date: Thu, 06 Mar 2014 17:00:45 -0500 (EST)
Message-ID: <20140306.170045.153273712993418795.davem@davemloft.net>
References: <1394016556-12358-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kumaras@chelsio.com, dm@chelsio.com,
	leedom@chelsio.com, santosh@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751817AbaCFWAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 17:00:48 -0500
In-Reply-To: <1394016556-12358-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed,  5 Mar 2014 16:19:16 +0530

> Commit 0034b29 (cxgb4: Don't assume LSO only uses SGL path in t4_eth_xmit())
> introduced a regression causing chip-hang. This patch needs more debugging and
> more work. So reverting for now.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

As requested I'm skipping this patch.
