From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] r8152: random MAC address
Date: Fri, 05 Sep 2014 12:18:05 -0700 (PDT)
Message-ID: <20140905.121805.2149838652698517913.davem@davemloft.net>
References: <1394712342-15778-26-Taiwan-albertk@realtek.com>
	<1394712342-15778-32-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-32-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 4 Sep 2014 16:15:40 +0800

> If the interface has invalid MAC address, it couldn't
> be used. In order to let it work normally, give a
> random one.
> 
> v3:
>   Remove
> 	ether_addr_copy(dev->perm_addr, dev->dev_addr);
> 
> v2:
>   Use "%pM" format specifier for printing a MAC address.

Series applied, thanks.
