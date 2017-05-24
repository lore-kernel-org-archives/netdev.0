From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] net: phy: marvell: Limit errata to 88m1101
Date: Wed, 24 May 2017 15:49:40 -0400 (EDT)
Message-ID: <20170524.154940.1077936120098835846.davem@davemloft.net>
References: <1495554553-21118-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966669AbdEXTtm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 15:49:42 -0400
In-Reply-To: <1495554553-21118-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 23 May 2017 17:49:13 +0200

> The 88m1101 has an errata when configuring autoneg. However, it was
> being applied to many other Marvell PHYs as well. Limit its scope to
> just the 88m1101.
> 
> Fixes: 76884679c644 ("phylib: Add support for Marvell 88e1111S and 88e1145")
> Reported-by: Daniel Walker <danielwa@cisco.com>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Acked-by: Harini Katakam <harinik@xilinx.com>

Applied and queued up for -stable, thanks.
