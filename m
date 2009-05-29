From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] korina: periodically poll the media
Date: Fri, 29 May 2009 01:52:44 -0700 (PDT)
Message-ID: <20090529.015244.198441309.davem@davemloft.net>
References: <200905281258.41956.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49232
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753979AbZE2Iwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:52:44 -0400
In-Reply-To: <200905281258.41956.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Thu, 28 May 2009 12:58:41 +0200

> This patch makes the korina driver poll the media
> for link change. This is actually required on
> Mikrotik RB532 (not RB532A) for korina to
> operate properly.
> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied, thanks.
