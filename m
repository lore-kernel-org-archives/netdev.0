From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] genetlink: define lockdep_genl_is_held() when
 CONFIG_LOCKDEP
Date: Tue, 24 Jul 2012 00:01:45 -0700 (PDT)
Message-ID: <20120724.000145.228972610625389483.davem@davemloft.net>
References: <1343108641-8439-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jesse@nicira.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185Ab2GXHBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 03:01:46 -0400
In-Reply-To: <1343108641-8439-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 24 Jul 2012 13:44:01 +0800

> From: WANG Cong <xiyou.wangcong@gmail.com>
> 
> lockdep_is_held() is defined when CONFIG_LOCKDEP, not CONFIG_PROVE_LOCKING.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jesse Gross <jesse@nicira.com>
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

Applied, thanks.
