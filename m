From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: Fix duplicate object rule
Date: Thu, 09 Feb 2017 17:11:19 -0500 (EST)
Message-ID: <20170209.171119.1472167082454813521.davem@davemloft.net>
References: <20170208224004.11786-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51584 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932350AbdBIWLV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 17:11:21 -0500
In-Reply-To: <20170208224004.11786-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed,  8 Feb 2017 14:40:04 -0800

> While adding switch.o to the list of DSA object files, we essentially
> duplicated the previous obj-y line and just added switch.o, remove the
> duplicate.
> 
> Fixes: f515f192ab4f ("net: dsa: add switch notifier")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
