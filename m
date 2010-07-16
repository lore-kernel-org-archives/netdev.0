From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/25] isdn/hardware/mISDN: Convert pci_table entries
 to PCI_VDEVICE (if PCI_ANY_ID is used)
Date: Thu, 15 Jul 2010 19:06:53 -0700 (PDT)
Message-ID: <20100715.190653.260081840.davem@davemloft.net>
References: <201007152102.38008.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, isdn@linux-pingi.de,
	u.kleine-koenig@pengutronix.de, tj@kernel.org, jkosina@suse.cz,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: PeterHuewe@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49836
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935205Ab0GPCGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 22:06:38 -0400
In-Reply-To: <201007152102.38008.PeterHuewe@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Huewe <PeterHuewe@gmx.de>
Date: Thu, 15 Jul 2010 21:02:36 +0200

> From: Peter Huewe <peterhuewe@gmx.de>
> 
> This patch converts pci_table entries, where .subvendor=PCI_ANY_ID and
> .subdevice=PCI_ANY_ID, .class=0 and .class_mask=0, to use the
> PCI_VDEVICE macro, and thus improves readability.
> 
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>

Applied.
