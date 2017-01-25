From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 1/1] net sched actions: Add support for
 user cookies
Date: Wed, 25 Jan 2017 12:38:52 -0500 (EST)
Message-ID: <20170125.123852.505805044649894592.davem@davemloft.net>
References: <1485259361-16860-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55514 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751964AbdAYRiy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 12:38:54 -0500
In-Reply-To: <1485259361-16860-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Tue, 24 Jan 2017 07:02:41 -0500

> Introduce optional 128-bit action cookie.

Applied, but like Jiri I think you can use one buffer instead of two
to store the user's cookie data.

Thanks.
