From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: dsa: bcm_sf2: misc bugfixes
Date: Tue, 25 Nov 2014 22:39:18 -0500 (EST)
Message-ID: <20141125.223918.1199525512212985299.davem@davemloft.net>
References: <1416967711-32494-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaKZDjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 22:39:21 -0500
In-Reply-To: <1416967711-32494-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 25 Nov 2014 18:08:29 -0800

> This patch series contains two bug fixes:
> 
> - first patch fixes an issue on the error path of the driver where we could
>   have left some of our registers mapped
> 
> - second patch enforces the use of a software reset of the switch to guarantee
>   the HW is in a consistent state prior to software initialization

Series applied, thanks Florian.
