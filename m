From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] net_sched: actions - Add default lookup and walker
Date: Thu, 05 Dec 2013 19:29:52 -0500 (EST)
Message-ID: <20131205.192952.291939460302313619.davem@davemloft.net>
References: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com, ebiederm@xmission.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426Ab3LFA34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 19:29:56 -0500
In-Reply-To: <1386167216-30281-1-git-send-email-jhs@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Wed,  4 Dec 2013 09:26:51 -0500

> This set of patches provide defaults for lookup and walkers for actions.
> Users can override when needed.
> It also enforces mandatory action methods to be passed.
> 
> Thanks to David Miller who paid attention and made this patch set 
> much better.

This looks great, applied, thanks Jamal.
