From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] driver: dummy: Fix one possbile memleak when
 fail to register_netdevice
Date: Sun, 30 Apr 2017 22:53:36 -0400 (EDT)
Message-ID: <20170430.225336.754367857537363635.davem@davemloft.net>
References: <1493437186-26727-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, phil@nwl.cc, stephen@networkplumber.org,
        zhangshengju@cmss.chinamobile.com, netdev@vger.kernel.org
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54698 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751799AbdEACxi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:53:38 -0400
In-Reply-To: <1493437186-26727-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please, Gao, submit this as a proper, numbered, patch series
with a proper header posting.

That way you can explain why you took this strategy to fix
this problem, compared to your original approach.

Thanks.
