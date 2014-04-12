From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: check RTL8152_UNPLUG
Date: Sat, 12 Apr 2014 02:01:20 -0400 (EDT)
Message-ID: <20140412.020120.1042243807724903382.davem@davemloft.net>
References: <1394712342-15778-4-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	sejeong.na@samsung.com
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-4-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 11 Apr 2014 17:54:31 +0800

> When the device is unplugged, the driver would try to disable the
> device. Add checking the flag of RTL8152_UNPLUG to skip setting
> the device when it is unplugged. This could shorten the time of
> unloading the driver.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
