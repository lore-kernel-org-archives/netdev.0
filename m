From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] ISDN: Add PCI ID for HFC-2S/4S Beronet Card PCIe
Date: Mon, 15 Mar 2010 19:09:36 -0700 (PDT)
Message-ID: <20100315.190936.56187308.davem@davemloft.net>
References: <1268668176.12629@pingi>
	<1268702879.31146@pingi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, lars.ellenberg@linbit.com,
	netdev@vger.kernel.org, andreas@eversberg.eu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: keil@b1-systems.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268702879.31146@pingi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karsten Keil <keil@b1-systems.de>
Date: Mon, 15 Mar 2010 14:18:41 +0100

> From: Lars Ellenberg <lars.ellenberg@linbit.com>
> 
> A few subdevice IDs seem to have been dropped when hfc_multi was
> included upstream, just compare the list at
> http://www.openvox.cn/viewvc/misdn/trunk/hfc_multi.c?revision=75&view=annotate#l175
> with the IDs in drivers/isdn/hardware/mISDN/hfcmulti.c
> 
> Added PCIe 2 Port card and LED settings (same as PCI)
> Do not use <linux/pci_ids.h> /KKe
> 
> Signed-off-by: Lars Ellenberg <lars.ellenberg@linbit.com>
> Signed-off-by: Karsten Keil <keil@b1-systems.de>

Applied, thanks.
