From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/openvswitch: Set the ipv6 source tunnel key
 address attribute correctly
Date: Wed, 15 Mar 2017 15:11:18 -0700 (PDT)
Message-ID: <20170315.151118.335264369893582168.davem@davemloft.net>
References: <1489594247-8601-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, paulb@mellanox.com, roid@mellanox.com,
        mlxsw@mellanox.com, netdev@vger.kernel.org
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdCOWLU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 18:11:20 -0400
In-Reply-To: <1489594247-8601-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 15 Mar 2017 18:10:47 +0200

> When dealing with ipv6 source tunnel key address attribute
> (OVS_TUNNEL_KEY_ATTR_IPV6_SRC) we are wrongly setting the tunnel
> dst ip, fix that.
> 
> Fixes: 6b26ba3a7d95 ('openvswitch: netlink attributes for IPv6 tunneling')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reported-by: Paul Blakey <paulb@mellanox.com>

Applied and queued up for -stable, thanks!
