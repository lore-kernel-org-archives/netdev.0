From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: Add extack for route add/delete
 failures
Date: Mon, 22 May 2017 12:12:38 -0400 (EDT)
Message-ID: <20170522.121238.703529646170218803.davem@davemloft.net>
References: <20170521161205.36720-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752544AbdEVQMk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 12:12:40 -0400
In-Reply-To: <20170521161205.36720-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Sun, 21 May 2017 10:12:01 -0600

> Use the extack feature to improve error messages to user on route
> add and delete failures.

Looks good, series applied.

Thanks.
