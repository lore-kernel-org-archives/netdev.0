From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv6/dccp: do not inherit ipv6_mc_list from parent
Date: Thu, 11 May 2017 12:18:04 -0400 (EDT)
Message-ID: <20170511.121804.1512438261634911702.davem@davemloft.net>
References: <1494374394-24373-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753354AbdEKQSL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:18:11 -0400
In-Reply-To: <1494374394-24373-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  9 May 2017 16:59:54 -0700

> Like commit 657831ffc38e ("dccp/tcp: do not inherit mc_list from parent")
> we should clear ipv6_mc_list etc. for IPv6 sockets too.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
