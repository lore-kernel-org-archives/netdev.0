From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/10] tg3: Embrace pci_ioremap_bar()
Date: Fri, 21 Nov 2008 17:20:41 -0800 (PST)
Message-ID: <20081121.172041.158463034.davem@davemloft.net>
References: <1227295576.5622@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49175
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752741AbYKVBUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 20:20:42 -0500
In-Reply-To: <1227295576.5622@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 21 Nov 2008 11:01:54 -0800

> Per Dave Miller's suggestion, replace the remaining ioremap_nocache()
> call with pci_ioremap_bar().  Remove the two IORESOURCE_MEM checks as
> they are redundant.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
