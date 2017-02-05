From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/12] net: get rid of __napi_complete()
Date: Sun, 05 Feb 2017 17:16:32 -0500 (EST)
Message-ID: <20170205.171632.491203678628144671.davem@davemloft.net>
References: <20170204232502.22361-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43732 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751416AbdBEWQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 17:16:42 -0500
In-Reply-To: <20170204232502.22361-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sat,  4 Feb 2017 15:24:50 -0800

> This patch series removes __napi_complete() calls, in an effort
> to make NAPI API simpler and generalize GRO and napi_complete_done()

Nice cleanup, series applied, thanks Eric.
