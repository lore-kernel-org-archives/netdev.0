From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/sched: Removed unused vlan actions
 definition
Date: Thu, 06 Apr 2017 13:28:48 -0700 (PDT)
Message-ID: <20170406.132848.157879959013855127.davem@davemloft.net>
References: <1491408565-21606-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37762 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752296AbdDFU2u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 16:28:50 -0400
In-Reply-To: <1491408565-21606-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed,  5 Apr 2017 19:09:25 +0300

> Commit c7e2b9689ef "sched: introduce vlan action" added both the
> UAPI values for the vlan actions (TCA_VLAN_ACT_) and these two
> in-kernel ones which are not used, remove them.
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied.
