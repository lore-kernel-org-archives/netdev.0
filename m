From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Fix ndo_setup_tc comment
Date: Fri, 27 Jan 2017 09:15:21 -0500 (EST)
Message-ID: <20170127.091521.719751287975323113.davem@davemloft.net>
References: <20170126224417.10327-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
        jiri@mellanox.com, jhs@mojatatu.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932263AbdA0OPZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 09:15:25 -0500
In-Reply-To: <20170126224417.10327-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 26 Jan 2017 14:44:17 -0800

> Commit 16e5cc647173 ("net: rework setup_tc ndo op to consume
> general tc operand") changed the ndo_setup_tc() signature, but did not
> update the comments in netdevice.h, so do that now.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
