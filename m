From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:ethernet:aquantia: Add 2500/5000 mbit link modes
 support.
Date: Mon, 13 Feb 2017 12:26:08 -0500 (EST)
Message-ID: <20170213.122608.1741813028941681007.davem@davemloft.net>
References: <985062aeff6287805fa59f2d8a51636bc296ff47.1486672746.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Simon.Edelhaus@aquantia.com,
        Alexey.Andriyanov@aquantia.com
To: Pavel.Belous@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751693AbdBMR0J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 12:26:09 -0500
In-Reply-To: <985062aeff6287805fa59f2d8a51636bc296ff47.1486672746.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <Pavel.Belous@aquantia.com>
Date: Thu,  9 Feb 2017 23:53:10 +0300

> From: Pavel Belous <pavel.belous@aquantia.com>
> 
> Using new link mode indices instead deprecated SUPPORTED_/ADVERTISED_
> macro.
> 
> Added indication for 2500 and 5000mbit link modes (AQtion adapter already
> supports these speeds).
> 
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>

Applied to net-next, thanks.
