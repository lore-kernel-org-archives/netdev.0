From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: add IFLA_GROUP to ifla_policy
Date: Tue, 20 Jun 2017 15:36:39 -0400 (EDT)
Message-ID: <20170620.153639.1035357696332838525.davem@davemloft.net>
References: <20170619.144843.29898198404383350.davem@davemloft.net>
        <1497958523-9015-1-git-send-email-serhe.popovych@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: serhe.popovych@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42556 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751025AbdFTTgk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 15:36:40 -0400
In-Reply-To: <1497958523-9015-1-git-send-email-serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serhey Popovych <serhe.popovych@gmail.com>
Date: Tue, 20 Jun 2017 14:35:23 +0300

> Network interface groups support added while ago, however
> there is no IFLA_GROUP attribute description in policy
> and netlink message size calculations until now.
> 
> Add IFLA_GROUP attribute to the policy.
> 
> Fixes: cbda10fa97d7 ("net_device: add support for network device groups")
> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
> ---
>  v2: Rebased to kernel/git/davem/net.git

Applied and queued up for -stable.
