From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] spectrum: Convert fib event handlers to use
 container_of on info arg
Date: Sat, 21 Oct 2017 01:45:35 +0100 (WEST)
Message-ID: <20171021.014535.2176507529756982495.davem@davemloft.net>
References: <1508364098-29621-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, idosch@mellanox.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45838 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752925AbdJUApi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 20:45:38 -0400
In-Reply-To: <1508364098-29621-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed, 18 Oct 2017 15:01:38 -0700

> Use container_of to convert the generic fib_notifier_info into
> the event specific data structure.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Applied.
