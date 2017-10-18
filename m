From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Use pI6c in tcp tracepoint
Date: Wed, 18 Oct 2017 14:03:51 +0100 (WEST)
Message-ID: <20171018.140351.2168224898788433123.davem@davemloft.net>
References: <1508189042-19591-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32800 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753141AbdJRND6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 09:03:58 -0400
In-Reply-To: <1508189042-19591-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon, 16 Oct 2017 14:24:02 -0700

> The compact form for IPv6 addresses is more user friendly than the full
> version. For example:
>    compact: 2001:db8:1::1
>       full: 2001:0db8:0001:0000:0000:0000:0000:0004i
> 
> Update the tcp tracepoint to show the compact form.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied.
