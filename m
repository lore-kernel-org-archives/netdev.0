From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] sch_netem: some improvements and
 cleanups.
Date: Fri, 14 Feb 2014 00:15:54 -0500 (EST)
Message-ID: <20140214.001554.2044631299131645638.davem@davemloft.net>
References: <1392345043-12208-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbaBNFPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 00:15:55 -0500
In-Reply-To: <1392345043-12208-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Fri, 14 Feb 2014 10:30:40 +0800

> v1 -> v2:
> 	remove patch #4.
> 
>  patch 1/3: To avoid breaking old settings when we change failed,
> 	    do return errcode before doing setup.
>  pacth 2/3: Replace some functions' parameters, these functions
> 	    only need struct netem_sched_data *q.
>  patch 3/3: Replace magic numbers with enumerate for better readability.

Series applied.
