From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: correct the definition
Date: Wed, 21 Jun 2017 11:33:23 -0400 (EDT)
Message-ID: <20170621.113323.1446978942398484275.davem@davemloft.net>
References: <1394712342-15778-282-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-282-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 21 Jun 2017 11:25:18 +0800

> Replace VLAN_HLEN and CRC_SIZE with ETH_FCS_LEN.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
