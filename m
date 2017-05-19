From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] Check all RGMII phy mode variants
Date: Fri, 19 May 2017 19:42:14 -0400 (EDT)
Message-ID: <20170519.194214.524202632096560137.davem@davemloft.net>
References: <1495145624-29463-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, andrew@lunn.ch,
        linux-arm-kernel@lists.infradead.org, patches@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754052AbdESXm2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 19:42:28 -0400
In-Reply-To: <1495145624-29463-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Thu, 18 May 2017 15:13:42 -0700

> This patch set,
>      - adds phy_interface_mode_is_rgmii() helper function
>      - addresses review comment from previous patch set, by calling
>        phy_interface_mode_is_rgmii() to address all RGMII variants
> 
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

Series applied, thanks.
