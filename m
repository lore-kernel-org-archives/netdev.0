From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7 v3] au1000-eth: fix bad printk usages
Date: Thu, 09 Sep 2010 21:37:31 -0700 (PDT)
Message-ID: <20100909.213731.68148547.davem@davemloft.net>
References: <201009082311.45685.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53158
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752063Ab0IJEhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 00:37:13 -0400
In-Reply-To: <201009082311.45685.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 8 Sep 2010 23:11:45 +0200

> 
> Use pr_(info|err) and pr_cont where required instead of calls to printk.
> Add missing pr_fmt to the driver.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied, please consider Joe Perches's feedback.

Thanks.
