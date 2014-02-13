From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3 0/5] net_sched: act: more cleanup and
 improvement
Date: Wed, 12 Feb 2014 19:24:20 -0500 (EST)
Message-ID: <20140212.192420.925537067553551934.davem@davemloft.net>
References: <1392167255-21744-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbaBMAYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 19:24:22 -0500
In-Reply-To: <1392167255-21744-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 11 Feb 2014 17:07:30 -0800

> v2 -> v3:
> * fix a mis-splitted patch
> * keep hinfo as a pointer in ops
> 
> v1 -> v2:
> * Fix a bug noticed by Jamal
> * Drop patches already merged into net-next
> * Add patch 5/5
> 
> Patches are cleanup's for the structures of tc actions, except patch 4
> which is an improvement.
> 
> See each patch for details.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Series applied, thanks.
