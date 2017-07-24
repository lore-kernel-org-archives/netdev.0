From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun/tap: Add the missed return value check of
 register_netdevice_notifier
Date: Mon, 24 Jul 2017 13:45:09 -0700 (PDT)
Message-ID: <20170724.134509.1200121677424249511.davem@davemloft.net>
References: <1500543694-23465-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiangxia.m.yue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42772 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755691AbdGXUpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 16:45:10 -0400
In-Reply-To: <1500543694-23465-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Date: Thu, 20 Jul 2017 02:41:34 -0700

> There is some codes of tun/tap module which did not check the return
> value of register_netdevice_notifier. Add the check now.
> 
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>

Applied.
