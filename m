From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] ipv4: remove ip_rt_dump from route.c
Date: Mon, 24 Mar 2014 12:50:23 -0400 (EDT)
Message-ID: <20140324.125023.1934266874345021813.davem@davemloft.net>
References: <1395372790-11056-1-git-send-email-roy.qing.li@gmail.com>
	<20140321.153844.1012685520499183330.davem@davemloft.net>
	<CAJFZqHxT2MxtmKsRG=AQ-fX4XS18zvLizGcQL_dPLRgCn=bodA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbaCXQu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 12:50:28 -0400
In-Reply-To: <CAJFZqHxT2MxtmKsRG=AQ-fX4XS18zvLizGcQL_dPLRgCn=bodA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>
Date: Mon, 24 Mar 2014 13:22:50 +0800

> On Sat, Mar 22, 2014 at 3:38 AM, David Miller <davem@davemloft.net> wrote:
>> From: roy.qing.li@gmail.com
>> Date: Fri, 21 Mar 2014 11:33:10 +0800
>>
>>> From: Li RongQing <roy.qing.li@gmail.com>
>>>
>>> ip_rt_dump do nothing after IPv4 route caches removal, so we can remove it.
>>>
>>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
>>
>> Applied, thanks.
> 
> Seems this patch was lost, I did not see it in net-next

I forgot to push it out Friday before leaving the office, it'll be in the
tree momentarily.
