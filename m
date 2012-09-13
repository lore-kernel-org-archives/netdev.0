From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] net_sched: gred: eliminate redundant DP prio
 comparisons
Date: Thu, 13 Sep 2012 16:10:34 -0400 (EDT)
Message-ID: <20120913.161034.1836280545395007963.davem@davemloft.net>
References: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu>
	<1347549755-19438-2-git-send-email-david.ward@ll.mit.edu>
	<50521F3E.7010101@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.ward@ll.mit.edu, netdev@vger.kernel.org, brosler@cisco.com,
	cyril@ti.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756252Ab2IMUKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:10:36 -0400
In-Reply-To: <50521F3E.7010101@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Thu, 13 Sep 2012 14:00:30 -0400

> On 12-09-13 11:22 AM, David Ward wrote:
>> Each pair of DPs only needs to be compared once when searching for
>> a non-unique prio value.
>>
>> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> 
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
