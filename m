From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/25] isdn/hardware/eicon: Convert pci_table entries
 to PCI_VDEVICE (if PCI_ANY_ID is used)
Date: Thu, 15 Jul 2010 19:07:11 -0700 (PDT)
Message-ID: <20100715.190711.28819238.davem@davemloft.net>
References: <201007152104.45958.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, mac@melware.de,
	isdn@linux-pingi.de, arnd@arndb.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: PeterHuewe@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49852
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935335Ab0GPCGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 22:06:55 -0400
In-Reply-To: <201007152104.45958.PeterHuewe@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Huewe <PeterHuewe@gmx.de>
Date: Thu, 15 Jul 2010 21:04:45 +0200

> From: Peter Huewe <peterhuewe@gmx.de>
> 
> This patch converts pci_table entries, where .subvendor=PCI_ANY_ID and
> .subdevice=PCI_ANY_ID, .class=0 and .class_mask=0, to use the
> PCI_VDEVICE macro, and thus improves readability.
> 
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>

Applied.
