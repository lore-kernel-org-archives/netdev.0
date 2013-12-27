From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] tipc: make the code look more readable
Date: Thu, 26 Dec 2013 23:04:15 -0500 (EST)
Message-ID: <20131226.230415.76472710052184859.davem@davemloft.net>
References: <1387263827-20876-3-git-send-email-wangweidong1@huawei.com>
	<52BCDBA4.9050607@huawei.com>
	<52BCDD0C.6030508@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangweidong1@huawei.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754218Ab3L0EER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 23:04:17 -0500
In-Reply-To: <52BCDD0C.6030508@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Fri, 27 Dec 2013 09:51:08 +0800

> On 12/27/2013 09:45 AM, Wang Weidong wrote:
>> In commit 3b8401fe9d ("tipc: kill unnecessary goto's") didn't make
>> the code look most readable, so fix it. This patch is cosmetic
>> and does not change the operation of TIPC in any way.
>> 
>> v3: fix the spelling error which pointed out by Sergei.
>> 
>> v2: fix the problem "Referring commit purely by
>>     SHA1 ID is ambiguous" which pointed out by David.
>> 
> 
> Please don't add review version history into patch head comments.

And please _always_ resubmit the entire series, not just the patches
you are changing.
