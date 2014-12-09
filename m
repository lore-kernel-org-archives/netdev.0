From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/6] net_sched: cls_*: couple of fixes
Date: Mon, 08 Dec 2014 20:53:53 -0500 (EST)
Message-ID: <20141208.205353.1940103999805714976.davem@davemloft.net>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59239 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbaLIBx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 20:53:56 -0500
In-Reply-To: <1417539636-12710-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  2 Dec 2014 18:00:30 +0100

> Jiri Pirko (6):
>   net_sched: cls_basic: remove unnecessary iteration and use passed arg
>   net_sched: cls_bpf: remove unnecessary iteration and use passed arg
>   net_sched: cls_bpf: remove faulty use of list_for_each_entry_rcu
>   net_sched: cls_flow: remove faulty use of list_for_each_entry_rcu
>   net_sched: cls_flow: remove duplicate assignments
>   net_sched: cls_cgroup: remove unnecessary if

Series applied, thanks Jiri.
