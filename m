From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cpmac: fix all checkpatch errors and warnings
Date: Tue, 17 Aug 2010 02:35:00 -0700 (PDT)
Message-ID: <20100817.023500.189722094.davem@davemloft.net>
References: <201008082209.40403.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34292
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932268Ab0HQJem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 05:34:42 -0400
In-Reply-To: <201008082209.40403.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Sun, 8 Aug 2010 22:09:39 +0200

> This patches fixes a couple of checkpatch warnings and errors:
> - lines over 80 columns
> - printk() instead of pr_cont()
> - assignments in tests (if ((foo == bar())))
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied.
