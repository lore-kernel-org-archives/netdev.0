From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix a slab object leak
Date: Wed, 01 Apr 2015 00:19:49 -0400 (EDT)
Message-ID: <20150401.001949.2023373520163186037.davem@davemloft.net>
References: <1427852570-25210-1-git-send-email-ying.xue@windriver.com>
	<20150331.231309.610369858855748160.davem@davemloft.net>
	<551B62FC.8030303@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbbDAETv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 00:19:51 -0400
In-Reply-To: <551B62FC.8030303@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 1 Apr 2015 11:16:12 +0800

> On 04/01/2015 11:13 AM, David Miller wrote:
>> This bug exists in 'net', so that's where I'm applying it.
>> 
>> Can you please target your patches properly, I shouldn't be
>> doing this kind of work for you.
> 
> Sure, I will recreate the patch targeted at "net" tree.

I said I applied it, there is nothing for you to do.
