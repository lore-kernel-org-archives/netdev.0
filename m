From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net/sched: cls_flower: Fix mask handling
Date: Sat, 17 Dec 2016 10:45:02 -0500 (EST)
Message-ID: <20161217.104502.169685502825654220.davem@davemloft.net>
References: <1481734858-37474-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, shahark@mellanox.com, hadarh@mellanox.com
To: paulb@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40702 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753384AbcLQPpE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 10:45:04 -0500
In-Reply-To: <1481734858-37474-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>
Date: Wed, 14 Dec 2016 19:00:56 +0200

> The series fix how the mask is being handled.

I guess this is reasonable, series applied, thanks.
