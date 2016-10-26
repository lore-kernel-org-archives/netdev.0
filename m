From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Broadcom BCM54612E support
Date: Wed, 26 Oct 2016 17:16:05 -0400 (EDT)
Message-ID: <20161026.171605.2216738980188763095.davem@davemloft.net>
References: <1477070413-92621-1-git-send-email-xow@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, jaedon.shin@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        openbmc@lists.ozlabs.org, joel@jms.id.au
To: xow@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42036 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754127AbcJZVQJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 17:16:09 -0400
In-Reply-To: <1477070413-92621-1-git-send-email-xow@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xo Wang <xow@google.com>
Date: Fri, 21 Oct 2016 10:20:11 -0700

> This series is based on tip of torvalds/master.
> 
> The first patch adds register definitions from Broadcom docs.
> 
> The second patch adds the BCM54612E PHY ID, flags, and device-specific
> RGMII internal delay initialization.
> 
> I tested on a custom board with an Aspeed AST2500 SOC with its second
> MAC connected to this PHY.

Series applied to net-next, thanks.
