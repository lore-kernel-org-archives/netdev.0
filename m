From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: set RTL8152_UNPLUG when finding -ENODEV
Date: Thu, 30 Oct 2014 16:55:44 -0400 (EDT)
Message-ID: <20141030.165544.2129434076908845307.davem@davemloft.net>
References: <1394712342-15778-73-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-73-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 30 Oct 2014 11:46:40 +0800

> Set RTL8152_UNPLUG when finding -ENODEV. This could accelerate
> unloading the driver when the device is unplugged.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
