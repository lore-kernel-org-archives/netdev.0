From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] bonding: fix 802.3ad support for 5G and 50G
 speeds
Date: Thu, 08 Jun 2017 16:05:54 -0400 (EDT)
Message-ID: <20170608.160554.2203162035278317553.davem@davemloft.net>
References: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751475AbdFHUF4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 16:05:56 -0400
In-Reply-To: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  8 Jun 2017 11:18:11 +0200

> From: Thibaut Collet <thibaut.collet@6wind.com>
> 
> This patch adds [5|50] Gbps enum definition, and fixes
> aggregated bandwidth calculation based on above slave links.
> 
> Fixes: c9a70d43461d ("net-next: ethtool: Added port speed macros.")
> Signed-off-by: Thibaut Collet <thibaut.collet@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
