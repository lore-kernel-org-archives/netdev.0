From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: Remove stale comments referencing
 timer
Date: Thu, 27 Jul 2017 17:27:57 -0700 (PDT)
Message-ID: <20170727.172757.99045256740169790.davem@davemloft.net>
References: <20170726190538.27674-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, slash.tmp@free.fr
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39064 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751551AbdG1A17 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 20:27:59 -0400
In-Reply-To: <20170726190538.27674-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 26 Jul 2017 12:05:38 -0700

> Since commit a390d1f379cf ("phylib: convert state_queue work to
> delayed_work"), the PHYLIB state machine was converted to use delayed
> workqueues, yet some functions were still referencing the PHY library
> timer in their comments, fix that and remove the now unused
> linux/timer.h include.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
