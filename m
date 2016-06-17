From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: modify the check of the flag of
 PHY_RESET in set_speed function
Date: Thu, 16 Jun 2016 17:08:45 -0700 (PDT)
Message-ID: <20160616.170845.2279392229071392054.davem@davemloft.net>
References: <1394712342-15778-183-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-183-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 16 Jun 2016 14:08:29 +0800

> In set_speed(), BMCR_RESET would be set when the flag of PHY_RESET
> is set. Use BMCR_RESET to replace testing the flag of PHY_RESET.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
