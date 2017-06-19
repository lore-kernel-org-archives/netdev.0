From: David Miller <davem@davemloft.net>
Subject: Re: rtnetlink: add IFLA_GROUP to ifla_policy
Date: Mon, 19 Jun 2017 14:47:44 -0400 (EDT)
Message-ID: <20170619.144744.209058927576395447.davem@davemloft.net>
References: <1497615744-25657-1-git-send-email-serhe.popovych@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: serhe.popovych@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36948 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753604AbdFSSrq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 14:47:46 -0400
In-Reply-To: <1497615744-25657-1-git-send-email-serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serhey Popovych <serhe.popovych@gmail.com>
Date: Fri, 16 Jun 2017 15:22:24 +0300

> Network interface groups support added while ago, however
> there is no IFLA_GROUP attribute description in policy
> and netlink message size calculations until now.
> 
> Add IFLA_GROUP attribute to the policy.
> 
> Fixes: cbda10fa97d7 ("net_device: add support for network device groups")
> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>

Applied and queued up for -stable, thanks.
