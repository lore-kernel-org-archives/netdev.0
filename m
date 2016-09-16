From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/3] net/sched: cls_flower: Add ports masks
Date: Thu, 15 Sep 2016 20:28:02 -0400 (EDT)
Message-ID: <20160915.202802.1596982643120333947.davem@davemloft.net>
References: <1473942504-23216-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, netdev@vger.kernel.org, hadarh@mellanox.com,
        paulb@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59552 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755039AbcIPA2F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 20:28:05 -0400
In-Reply-To: <1473942504-23216-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 15 Sep 2016 15:28:21 +0300

> This series adds the ability to specify tcp/udp ports masks 
> for TC/flower filter matches.
> 
> I also removed an unused fields from the flower keys struct 
> and clarified the format of the recently added vlan attibutes.

Series applied.
