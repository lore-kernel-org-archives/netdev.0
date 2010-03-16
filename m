From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ISDN: Add PCI ID for HFC-2S/4S Beronet Card PCIe
Date: Mon, 15 Mar 2010 19:06:53 -0700 (PDT)
Message-ID: <20100315.190653.247529535.davem@davemloft.net>
References: <1268668176.12629@pingi>
	<20100315.160133.67908104.davem@davemloft.net>
	<201003160208.57232.keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, lars.ellenberg@linbit.com,
	netdev@vger.kernel.org, andreas@eversberg.eu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: keil@b1-systems.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003160208.57232.keil@b1-systems.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karsten Keil <keil@b1-systems.de>
Date: Tue, 16 Mar 2010 02:08:57 +0100

> Is here some plan to cleanup drivers for -next and remove IDs from pci_ids.h,
> or should it not changed for old  entries ?

Leave things as they are for existing ones.
