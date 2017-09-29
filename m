From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: remove fib_info arg to fib_check_nh
Date: Fri, 29 Sep 2017 06:20:34 +0100 (WEST)
Message-ID: <20170929.062034.1665077970726144815.davem@davemloft.net>
References: <1506570119-17088-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45770 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbdI2LPd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 07:15:33 -0400
In-Reply-To: <1506570119-17088-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Wed, 27 Sep 2017 20:41:59 -0700

> fib_check_nh does not use the fib_info arg; remove t.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied.
