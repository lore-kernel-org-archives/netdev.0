From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net sched actions police: peg drop stats
 for conforming traffic
Date: Mon, 19 Sep 2016 22:04:26 -0400 (EDT)
Message-ID: <20160919.220426.2107255800220515369.davem@davemloft.net>
References: <1474199588-11032-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mrv@mojatatu.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbcITCE3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 22:04:29 -0400
In-Reply-To: <1474199588-11032-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 18 Sep 2016 07:53:08 -0400

> From: Roman Mashak <mrv@mojatatu.com>
> 
> setting conforming action to drop is a valid policy.
> When it is set we need to at least see the stats indicating it
> for debugging.
> 
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
