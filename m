From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: Change the RX LAG hash function from
 XOR to CRC
Date: Tue, 20 Sep 2016 04:33:21 -0400 (EDT)
Message-ID: <20160920.043321.1312355503685864522.davem@davemloft.net>
References: <1474266504-5723-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932197AbcITId2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 04:33:28 -0400
In-Reply-To: <1474266504-5723-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 19 Sep 2016 08:28:24 +0200

> From: Elad Raz <eladr@mellanox.com>
> 
> Change the RX hash function from XOR to CRC in order to have better
> distribution of the traffic.
> 
> Signed-off-by: Elad Raz <eladr@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
