From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 2/6] net_sched: act: export tcf_hash_search()
 instead of tcf_hash_lookup()
Date: Tue, 21 Jan 2014 14:44:03 -0800 (PST)
Message-ID: <20140121.144403.1534466685310614100.davem@davemloft.net>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389987427-14085-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754509AbaAUWoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 17:44:04 -0500
In-Reply-To: <1389987427-14085-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 17 Jan 2014 11:37:03 -0800

> So that we will not expose struct tcf_common to modules.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
