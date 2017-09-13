From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net v3 0/3] net_sched: fix filter chain reference
 counting
Date: Tue, 12 Sep 2017 20:41:18 -0700 (PDT)
Message-ID: <20170912.204118.1990439437521288402.davem@davemloft.net>
References: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com,
        jakub.kicinski@netronome.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751381AbdIMDlT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 23:41:19 -0400
In-Reply-To: <20170911233332.7594-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 11 Sep 2017 16:33:29 -0700

> This patchset fixes tc filter chain reference counting and nasty race
> conditions with RCU callbacks. Please see each patch for details.

Series applied, thanks Cong.
