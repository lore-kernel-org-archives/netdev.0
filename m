From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v10 0/7] cxgb4/cxgbi: misc. fixes for cxgb4i
Date: Fri, 12 Dec 2014 11:22:51 -0500 (EST)
Message-ID: <20141212.112251.421931987515352352.davem@davemloft.net>
References: <201412120313.sBC3DQhF028321@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	hariprasad@chelsio.com, anish@chelsio.com, hch@infradead.org,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu
To: kxie@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030408AbaLLQWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 11:22:54 -0500
In-Reply-To: <201412120313.sBC3DQhF028321@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karen Xie <kxie@chelsio.com>
Date: Thu, 11 Dec 2014 19:13:26 -0800

> This patch set fixes cxgb4i's tx credit calculation and adds handling of
> additional rx message and negative advice types. It also removes the duplicate
> code in cxgb4i to set the outgoing queues of a packet. 

Series applied, thanks.
