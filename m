From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net sched filters: fix filter handle ID in
 tfilter_notify_chain()
Date: Thu, 24 Nov 2016 16:06:20 -0500 (EST)
Message-ID: <20161124.160620.703038887504914339.davem@davemloft.net>
References: <1479866224-12285-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net
To: mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41746 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965927AbcKXVG3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 16:06:29 -0500
In-Reply-To: <1479866224-12285-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>
Date: Tue, 22 Nov 2016 20:57:04 -0500

> Should pass valid filter handle, not the netlink flags.
> 
> Fixes: 30a391a13ab92 ("net sched filters: pass netlink message flags in event notification")
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
