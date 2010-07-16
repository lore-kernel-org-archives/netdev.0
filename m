From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/25] atm: Convert pci_table entries to PCI_VDEVICE
 (if PCI_ANY_ID is used)
Date: Thu, 15 Jul 2010 19:06:44 -0700 (PDT)
Message-ID: <20100715.190644.48498742.davem@davemloft.net>
References: <201007152049.33395.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, chas@cmf.nrl.navy.mil,
	tj@kernel.org, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: PeterHuewe@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49827
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935305Ab0GPCG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 22:06:28 -0400
In-Reply-To: <201007152049.33395.PeterHuewe@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Huewe <PeterHuewe@gmx.de>
Date: Thu, 15 Jul 2010 20:49:32 +0200

> From: Peter Huewe <peterhuewe@gmx.de>
> 
> This patch converts pci_table entries, where .subvendor=PCI_ANY_ID and
> .subdevice=PCI_ANY_ID, .class=0 and .class_mask=0, to use the
> PCI_VDEVICE macro, and thus improves readability.
> 
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>

Applied.
