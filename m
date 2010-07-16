From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 22/25] mISDN: Convert pci_table entries to PCI_VDEVICE
 (if PCI_ANY_ID is used)
Date: Thu, 15 Jul 2010 19:07:16 -0700 (PDT)
Message-ID: <20100715.190716.102544882.davem@davemloft.net>
References: <201007152105.39404.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, isdn@linux-pingi.de,
	akpm@linux-foundation.org, jkosina@suse.cz, roel.kluin@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: PeterHuewe@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201007152105.39404.PeterHuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Huewe <PeterHuewe@gmx.de>
Date: Thu, 15 Jul 2010 21:05:38 +0200

> From: Peter Huewe <peterhuewe@gmx.de>
> 
> This patch converts pci_table entries, where .subvendor=PCI_ANY_ID and
> .subdevice=PCI_ANY_ID, .class=0 and .class_mask=0, to use the
> PCI_VDEVICE macro, and thus improves readability.
> 
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>

Applied.
