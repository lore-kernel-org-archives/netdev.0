From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: fix a use-after-free in sfq
Date: Wed, 15 Jul 2015 21:36:52 -0700 (PDT)
Message-ID: <20150715.213652.1601490488555314827.davem@davemloft.net>
References: <1436898118-30804-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbbGPEgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 00:36:53 -0400
In-Reply-To: <1436898118-30804-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 14 Jul 2015 11:21:57 -0700

> Fixes: 25331d6ce42b ("net: sched: implement qstat helper routines")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Applied.
