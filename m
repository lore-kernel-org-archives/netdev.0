From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tun: timer cleanups
Date: Sun, 22 Oct 2017 03:15:28 +0100 (WEST)
Message-ID: <20171022.031528.2155331626728261485.davem@davemloft.net>
References: <20171020182957.32729-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jasowang@redhat.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57698 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932325AbdJVCPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 22:15:32 -0400
In-Reply-To: <20171020182957.32729-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri, 20 Oct 2017 11:29:54 -0700

> While working on a syzkaller issue that might have been
> fixed already by Cong Wang in commit 0ad646c81b21
> ("tun: call dev_get_valid_name() before register_netdevice()")
> I made three small changes related to flow_gc_timer.

Series applied, thanks Eric.
