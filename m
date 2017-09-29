From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: remove fib_weight
Date: Fri, 29 Sep 2017 06:20:27 +0100 (WEST)
Message-ID: <20170929.062027.805917002715752957.davem@davemloft.net>
References: <1506564480-20374-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45798 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751984AbdI2LPd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 07:15:33 -0400
In-Reply-To: <1506564480-20374-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed, 27 Sep 2017 19:08:00 -0700

> fib_weight in fib_info is set but not used. Remove it and the
> helpers for setting it.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied.
