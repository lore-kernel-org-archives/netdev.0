From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v7 0/2] net: sched: fix two issues
Date: Wed, 11 Dec 2013 15:09:06 -0500 (EST)
Message-ID: <20131211.150906.2254810460626115748.davem@davemloft.net>
References: <1386658768-29584-1-git-send-email-yangyingliang@huawei.com>
	<20131211.142032.645385003264171429.davem@davemloft.net>
	<1386790747.30495.381.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yangyingliang@huawei.com, netdev@vger.kernel.org,
	brouer@redhat.com, jpirko@redhat.com, jbrouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924Ab3LKUJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 15:09:08 -0500
In-Reply-To: <1386790747.30495.381.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Dec 2013 11:39:07 -0800

> On Wed, 2013-12-11 at 14:20 -0500, David Miller wrote:
>> From: Yang Yingliang <yangyingliang@huawei.com>
>> Date: Tue, 10 Dec 2013 14:59:26 +0800
>> 
>> > fix calculation of max_size in tbf
>> > fix quantum calculation introduced by 64bit rates.
>> 
>> Eric does this series look good to you now?
> 
> Yes it seems good now, thanks !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Series applied, thanks everyone.
