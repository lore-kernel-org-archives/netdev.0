From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun/tap: Add the missed return value check of
 register_netdevice_notifier
Date: Mon, 24 Jul 2017 20:49:02 -0700 (PDT)
Message-ID: <20170724.204902.702236719746923248.davem@davemloft.net>
References: <1500543694-23465-1-git-send-email-xiangxia.m.yue@gmail.com>
        <20170724.134509.1200121677424249511.davem@davemloft.net>
        <1EE7E264-429A-4E31-8F9B-B59965940497@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiangxia.m.yue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47356 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751917AbdGYDtF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 23:49:05 -0400
In-Reply-To: <1EE7E264-429A-4E31-8F9B-B59965940497@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Date: Tue, 25 Jul 2017 10:43:26 +0800

> One question, this type bugfix will be applied to net-next ?

'net' is periodically merged into 'net-next', so yes.
