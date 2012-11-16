From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use right lock in __dev_remove_offload
Date: Fri, 16 Nov 2012 13:41:33 -0500 (EST)
Message-ID: <20121116.134133.193993329336960361.davem@davemloft.net>
References: <1353089303.10798.38.camel@edumazet-glaptop>
	<50A682DA.2060201@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58567 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418Ab2KPSlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 13:41:35 -0500
In-Reply-To: <50A682DA.2060201@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Fri, 16 Nov 2012 13:15:54 -0500

> On 11/16/2012 01:08 PM, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> offload_base is protected by offload_lock, not ptype_lock
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
 ...
> Acked-by: Vlad Yasevich <vyasevic@redhat.com>

Applied, thanks everyone.
