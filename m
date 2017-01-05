From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net:mv88e6xxx: use g2 interrupt for 6097
 chip
Date: Thu, 05 Jan 2017 11:38:59 -0500 (EST)
Message-ID: <20170105.113859.990292394969644492.davem@davemloft.net>
References: <1483609458-24645-1-git-send-email-volodymyr.bendiuga@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        volodymyr.bendiuga@westermo.se
To: volodymyr.bendiuga@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38572 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752661AbdAEQjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 11:39:01 -0500
In-Reply-To: <1483609458-24645-1-git-send-email-volodymyr.bendiuga@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Date: Thu,  5 Jan 2017 10:44:18 +0100

> This chip needs MV88E6XXX_FLAG_G2_INT
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.
