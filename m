From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] bonding: fix 802.3ad support for 14G speed
Date: Thu, 08 Jun 2017 16:06:00 -0400 (EDT)
Message-ID: <20170608.160600.1905646283089963454.davem@davemloft.net>
References: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
        <1496913493-23293-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36122 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751719AbdFHUGC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 16:06:02 -0400
In-Reply-To: <1496913493-23293-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  8 Jun 2017 11:18:12 +0200

> This patch adds 14 Gbps enum definition, and fixes
> aggregated bandwidth calculation based on above slave links.
> 
> Fixes: 0d7e2d2166f6 ("IB/ipoib: add get_link_ksettings in ethtool")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
