From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/1] net sched actions: Add support for
 user cookies
Date: Tue, 17 Jan 2017 10:24:26 -0500 (EST)
Message-ID: <20170117.102426.1738397298019104514.davem@davemloft.net>
References: <1484488879-29560-2-git-send-email-jhs@emojatatu.com>
        <20170116.144644.977968311370245919.davem@davemloft.net>
        <bc3f6bc4-2896-0ba0-35f4-198204f9317d@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750855AbdAQPYa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 10:24:30 -0500
In-Reply-To: <bc3f6bc4-2896-0ba0-35f4-198204f9317d@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Tue, 17 Jan 2017 05:52:15 -0500

> Having said that: Is this rule really cast in stone?;->
> I have seen many other people (including myself) sneak in whitespace
> changes and other trivialities in a general change. I thought the rule
> was to not do such things for bug fixes.

Sneaking patches that do things they shouldn't past me doesn't make
it the new rule.
