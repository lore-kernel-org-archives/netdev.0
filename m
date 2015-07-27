From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4vf: Read correct FL congestion threshold
 for T5 and T6
Date: Sun, 26 Jul 2015 21:47:23 -0700 (PDT)
Message-ID: <20150726.214723.1269693979460233312.davem@davemloft.net>
References: <1437671474-30987-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbG0ErX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 00:47:23 -0400
In-Reply-To: <1437671474-30987-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu, 23 Jul 2015 22:41:14 +0530

> VF driver was reading incorrect freelist congestion notification threshold
> for FLM queues when packing is enabled for T5 and T6 adapter. Fixing it
> now.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
