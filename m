From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net_sched: two improvements to sch_netem
Date: Tue, 31 Dec 2013 14:33:23 -0500 (EST)
Message-ID: <20131231.143323.320853835047066887.davem@davemloft.net>
References: <1387964115-31168-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756438Ab3LaTdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 14:33:25 -0500
In-Reply-To: <1387964115-31168-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Wed, 25 Dec 2013 17:35:13 +0800

> This patchset makes two improvements to sch_netem.
> 
>  patch 1/2: Make bytes on wire more precise with qdisc_pkt_len().
>  patch 2/2: Add a new attribute to support 64-bit rates.
> 
> Yang Yingliang (2):
>   sch_netem: more precise length of packets
>   sch_netem: support of 64bit rates

Both applied, thank you.
