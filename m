From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] bcm63xx_enet: small fixes and cleanups
Date: Sun, 01 Oct 2017 23:06:12 -0700 (PDT)
Message-ID: <20171001.230612.48458482844813711.davem@davemloft.net>
References: <20171001110220.27668-1-jonas.gorski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.or, f.fainelli@gmail.com,
        bcm-kernel-feedback-list@broadcom.com
To: jonas.gorski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60920 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdJBGGN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 02:06:13 -0400
In-Reply-To: <20171001110220.27668-1-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Gorski <jonas.gorski@gmail.com>
Date: Sun,  1 Oct 2017 13:02:14 +0200

> This patch set fixes a few theoretical issues and cleans up the code a
> bit. It also adds a bit more managed function usage to simplify clock
> and iomem usage.
> 
> Based on net-next.

Series applied.
