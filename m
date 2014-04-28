From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] sched, act: allow to clear all actions as well
Date: Sun, 27 Apr 2014 23:42:58 -0400 (EDT)
Message-ID: <20140427.234258.331496805465979165.davem@davemloft.net>
References: <1398459330-15598-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbaD1Dm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 23:42:59 -0400
In-Reply-To: <1398459330-15598-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 25 Apr 2014 13:55:30 -0700

> From: Cong Wang <cwang@twopensource.com>
> 
> When we change the list of action on a given filter, currently we don't
> change it to empty. This is a bug, we should allow to change to whatever
> users given.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Applied.
