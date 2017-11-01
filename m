From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] PHYLINK cosmetic and build fixes
Date: Wed, 01 Nov 2017 21:17:25 +0900 (KST)
Message-ID: <20171101.211725.838722434104967515.davem@davemloft.net>
References: <20171031044258.16094-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, rmk+kernel@armlinux.org.uk
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52904 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752141AbdKAMRb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 08:17:31 -0400
In-Reply-To: <20171031044258.16094-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 30 Oct 2017 21:42:56 -0700

> Please find two small "fixes" one that corrects some stylistic changes and
> another one that fixes an actual build failure in sfp.c. Since PHYLINK is
> not directly visible to user, and there are no in-tree users yet (coming)
> this is not targeted at "net" but "net-next" instead.

Series applied, thanks Florian.
