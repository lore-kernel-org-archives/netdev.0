From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8169: disable L23
Date: Tue, 08 Jul 2014 19:59:57 -0700 (PDT)
Message-ID: <20140708.195957.83100573934289236.davem@davemloft.net>
References: <1394712342-15778-6-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nic_swsd@realtek.com
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-6-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 8 Jul 2014 16:26:10 +0800

> For RTL8411, RTL8111G, RTL8402, RTL8105, and RTL8106, the nic couldn't
> leave the power saving mode of L23 for certain situation. This causes
> the device lost for the system. Disable the L23 mode to avoid it.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

I agree with Francois, you need to provide a more detailed changelog
for this patch.
