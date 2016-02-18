From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] ixgbe: use u32 instead of __u32 in model
 header
Date: Wed, 17 Feb 2016 21:44:28 -0500 (EST)
Message-ID: <20160217.214428.1170108405038675056.davem@davemloft.net>
References: <20160217223453.9858.76096.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424140AbcBRCob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 21:44:31 -0500
In-Reply-To: <20160217223453.9858.76096.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 17 Feb 2016 14:34:53 -0800

> I incorrectly used __u32 types where we should be using u32 types when
> I added the ixgbe_model.h file.
> 
> Fixes: 9d35cf062e05 ("net: ixgbe: add minimal parser details for ixgbe")
> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
