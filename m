From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: unnecessary to check if vlan_pcpu_stats is NULL
Date: Fri, 04 Apr 2014 09:59:55 -0400 (EDT)
Message-ID: <20140404.095955.1722938838006349891.davem@davemloft.net>
References: <20140403.163603.2057792710871114160.davem@davemloft.net>
	<1396558866.12330.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJFZqHww77zYs+w8LUemPu6R7jHppmhLzYNR+NEPdtaV+wnM7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, edumazet@google.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbaDDN6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 09:58:20 -0400
In-Reply-To: <CAJFZqHww77zYs+w8LUemPu6R7jHppmhLzYNR+NEPdtaV+wnM7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>
Date: Fri, 4 Apr 2014 09:10:31 +0800

>> Right, this patch seems fine, thanks !
>>
>> Acked-by: Eric Dumazet <edumazet@google.com>
>>
>>
> 
> Thanks;
> This should be for net-next, not net; Thanks.

The net-next tree is closed, please resubmit when it opens back up.
