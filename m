From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bonding: warn user when 802.3ad speed is
 unknown
Date: Sat, 10 Jun 2017 16:07:21 -0400 (EDT)
Message-ID: <20170610.160721.2107730957657302852.davem@davemloft.net>
References: <20170609145932.GG20756@lunn.ch>
        <1497023888-1420-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33472 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751555AbdFJUHY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:07:24 -0400
In-Reply-To: <1497023888-1420-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri,  9 Jun 2017 17:58:08 +0200

> Goal is to advertise the user when ethtool speeds and 802.3ad speeds are
> desynchronized.
> When this case happens, the kernel needs to be patched.
> 
> Suggested-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks Nicolas.
