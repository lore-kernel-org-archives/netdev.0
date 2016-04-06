From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: fix a memory leak in tc action
Date: Wed, 06 Apr 2016 16:04:42 -0400 (EDT)
Message-ID: <20160406.160442.1696373861244273868.davem@davemloft.net>
References: <1459791168-16675-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbcDFUEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:04:44 -0400
In-Reply-To: <1459791168-16675-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon,  4 Apr 2016 10:32:48 -0700

> Fixes: ddf97ccdd7cb ("net_sched: add network namespace support for tc actions")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks Cong.
