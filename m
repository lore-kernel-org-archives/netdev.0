From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] r6040: fix version printing
Date: Sun, 15 Nov 2009 21:15:17 -0800 (PST)
Message-ID: <20091115.211517.150028073.davem@davemloft.net>
References: <200911151449.43750.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750761AbZKPFPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 00:15:01 -0500
In-Reply-To: <200911151449.43750.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Sun, 15 Nov 2009 14:49:43 +0100

> The version string already contains the printk level
> specifying it again results in the following message
> being printed:
> <6>r6040: RDC R6040 NAPI ...
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied, thanks.
