From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 2/3] MIPS: lantiq: add ethernet driver
Date: Thu, 05 May 2011 15:10:49 -0700 (PDT)
Message-ID: <20110505.151049.35056363.davem@davemloft.net>
References: <1304633402-24161-1-git-send-email-blogic@openwrt.org>
	<1304633402-24161-3-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, ralph.hempel@lantiq.com,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: blogic@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35099
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753066Ab1EEWLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 18:11:22 -0400
In-Reply-To: <1304633402-24161-3-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <blogic@openwrt.org>
Date: Fri,  6 May 2011 00:10:01 +0200

> This patch adds the driver for the ETOP Packet Processing Engine (PPE32) found
> inside the XWAY family of Lantiq MIPS SoCs. This driver makes 100MBit ethernet
> work. Support for all 8 dma channels, gbit and the embedded switch found on
> the ar9/vr9 still needs to be implemented.
> 
> Signed-off-by: John Crispin <blogic@openwrt.org>
> Signed-off-by: Ralph Hempel <ralph.hempel@lantiq.com>

No objections from me and this can go via the MIPS tree:

Acked-by: David S. Miller <davem@davemloft.net>
