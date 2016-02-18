From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: pack tc_cls_u32_knode struct slighter
 better
Date: Wed, 17 Feb 2016 21:44:45 -0500 (EST)
Message-ID: <20160217.214445.1513064463814557886.davem@davemloft.net>
References: <20160217225930.25736.17844.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424140AbcBRCor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 21:44:47 -0500
In-Reply-To: <20160217225930.25736.17844.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 17 Feb 2016 14:59:30 -0800

> By packing the structure we can remove a few holes as Jamal
> suggests.
> 
> before:
...
> after:
 ...
> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
