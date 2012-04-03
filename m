From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 03 Apr 2012 19:17:09 -0400 (EDT)
Message-ID: <20120403.191709.1232575113074905660.davem@davemloft.net>
References: <1333448001-2507-4-git-send-email-pablo@netfilter.org>
	<201204031927.AIJ09351.FQFMJOOVFSOtHL@I-love.SAKURA.ne.jp>
	<20120403103903.GA20689@1984>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755057Ab2DCXSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 19:18:17 -0400
In-Reply-To: <20120403103903.GA20689@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 3 Apr 2012 12:39:03 +0200

>>From e21e9622a46a60bd2b8dfb9791bb63dfdd4940d7 Mon Sep 17 00:00:00 2001
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Tue, 3 Apr 2012 12:32:15 +0200
> Subject: [PATCH] netfilter: xt_CT: allocation has to be GFP_ATOMIC under rcu_read_lock section
> 
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
