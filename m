From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net sched actions: fix refcnt when GETing of
 action after bind
Date: Mon, 16 Jan 2017 19:46:00 -0500 (EST)
Message-ID: <20170116.194600.2260386042902493113.davem@davemloft.net>
References: <1484493246-10911-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52342 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdAQAqI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 19:46:08 -0500
In-Reply-To: <1484493246-10911-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 15 Jan 2017 10:14:06 -0500

> From: Jamal Hadi Salim <jhs@mojatatu.com>
 ...
> Fixes: aecc5cefc389 ("net sched actions: fix GETing actions")
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied and queued up for -stable, thanks Jamal.
