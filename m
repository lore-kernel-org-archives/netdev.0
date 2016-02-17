From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/8] tc offload for cls_u32 on ixgbe
Date: Tue, 16 Feb 2016 20:17:12 -0500 (EST)
Message-ID: <20160216.201712.155104214233989878.davem@davemloft.net>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amir@vadai.me, jhs@mojatatu.com, netdev@vger.kernel.org,
	jiri@resnulli.us, jeffrey.t.kirsher@intel.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933275AbcBQBRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 20:17:15 -0500
In-Reply-To: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 15 Feb 2016 22:00:03 -0800

> This extends the setup_tc framework so it can support more than just
> the mqprio offload and push other classifiers and qdiscs into the
> hardware.
 ...

Jiri gave some minor stylistic feedback, please address that and
respin, and I'll apply this series.

Thanks John.
