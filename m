From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] ethtool.h: remind to update 802.3ad when
 adding new speeds
Date: Thu, 08 Jun 2017 16:06:05 -0400 (EDT)
Message-ID: <20170608.160605.1444985183382523336.davem@davemloft.net>
References: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
        <1496913493-23293-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36136 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdFHUGH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 16:06:07 -0400
In-Reply-To: <1496913493-23293-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  8 Jun 2017 11:18:13 +0200

> Each time a new speed is added, the bonding 802.3ad isn't updated. Add a
> comment to remind the developer to update this driver.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
