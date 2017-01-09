From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Add Meson GXL PHY hardware dependency
Date: Mon, 09 Jan 2017 16:38:58 -0500 (EST)
Message-ID: <20170109.163858.228878756915473380.davem@davemloft.net>
References: <20170109151727.6571f566@endymion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, narmstrong@baylibre.com,
        f.fainelli@gmail.com, andrew@lunn.ch
To: jdelvare@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51778 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936547AbdAIVjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:39:01 -0500
In-Reply-To: <20170109151727.6571f566@endymion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <jdelvare@suse.de>
Date: Mon, 9 Jan 2017 15:17:27 +0100

> As I understand it the Meson GXL PHY driver is only useful on one
> architecture so only make it visible on that architecture.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> Fixes: 7334b3e47aee ("net: phy: Add Meson GXL Internal PHY driver")

Applied.
