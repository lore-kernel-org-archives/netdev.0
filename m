From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] More marvell phy cleanups
Date: Fri, 26 May 2017 14:45:06 -0400 (EDT)
Message-ID: <20170526.144506.1223446037417985810.davem@davemloft.net>
References: <1495741328-25001-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43470 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754261AbdEZSpH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 14:45:07 -0400
In-Reply-To: <1495741328-25001-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 25 May 2017 21:42:04 +0200

> This patchset continues the cleanup of the Marvell PHY driver.  These
> phys use pages to allow more than the 32 registers that fit into the
> MDIO address space. Cleanup the code used for changing pages.
> 
> v2
> Reverse christmas tree

Series applied, thank you Andrew.
