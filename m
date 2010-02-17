From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 0/2] usbnet: Use (netdev|netif)_<level>
 macros
Date: Wed, 17 Feb 2010 13:38:46 -0800 (PST)
Message-ID: <20100217.133846.181531049.davem@davemloft.net>
References: <20100217.000422.246530855.davem@davemloft.net>
	<cover.1266438216.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, gregkh@suse.de, tilman@imap.cc,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266438216.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 17 Feb 2010 12:30:22 -0800

> Sorry 'bout that.
> I'll try to improve my insufficient grep and build testing.

'allmodconfig' works well for build testing.  :-)

> Added drivers/net/wireless/rndis_wlan.c to conversions.
> 
> After this conversion, no uses of the old macros exist in-tree.
> 
> Joe Perches (2):
>   usbnet: Convert dev(dbg|err|warn|info) macros to netdev_<level>
>   drivers/net/usb: Use netif_<level> logging facilities

All applied, thanks.
