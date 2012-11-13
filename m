From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch] vxlan: fix a typo.
Date: Tue, 13 Nov 2012 17:14:42 -0500 (EST)
Message-ID: <20121113.171442.858333742915732639.davem@davemloft.net>
References: <1352849355-5429-1-git-send-email-ramirose@gmail.com>
	<20121113133210.0fdef8af@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ramirose@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50448 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755122Ab2KMWOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 17:14:43 -0500
In-Reply-To: <20121113133210.0fdef8af@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 13 Nov 2012 13:32:10 -0800

> On Wed, 14 Nov 2012 01:29:15 +0200
> Rami Rosen <ramirose@gmail.com> wrote:
> 
>> Use eXtensible and not eXtensiable in the comment on top.
>> 
>> Signed-off-by: Rami Rosen <ramirose@gmail.com>
>> ---
>>  drivers/net/vxlan.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 8aca888..3204208 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -1,5 +1,5 @@
>>  /*
>> - * VXLAN: Virtual eXtensiable Local Area Network
>> + * VXLAN: Virtual eXtensible Local Area Network
>>   *
>>   * Copyright (c) 2012 Vyatta Inc.
>>   *
> 
> 
> This can go into net (3.7) if Linus is willing.
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to 'net', thanks.
