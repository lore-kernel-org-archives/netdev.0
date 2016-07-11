From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH v6] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Mon, 11 Jul 2016 21:54:07 +0000
Message-ID: <5eecdffa7a5d4121bcd2682c64aa57b2@ausx13mpc124.AMER.DELL.COM>
References: <201606141828.10969@pali>	<20160614164017.GB14477@kroah.com>
	<201606141847.36109@pali>
 <20160614.143521.2085426866285759820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <gregkh@linuxfoundation.org>, <andrew@lunn.ch>,
	<hayeswang@realtek.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<anthony.wong@canonical.com>
To: <davem@davemloft.net>, <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> David,
> 
> Did you have any more thoughts about this?  I'm happy to make some other
> adjustments to the patch, if you have some recommendations.

Hi,

I just wanted to share that the maintenance BIOSes released for the Dell 
platforms with Type-C this past week enables the MAC address pass 
through feature in UEFI, so any network booted machines will offer
the auxiliary MAC to the DHCP server.  In Windows a network booted
machine will always use auxiliary MAC now.

XPS 9350 (BIOS 1.4.4): http://goo.gl/7Sw2DZ

Please let me know what else can be done for this patch to make it
acceptable so we can have parity for Linux.

Thanks,
