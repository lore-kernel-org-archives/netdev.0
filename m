From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] r8152: couldn't read OCP_SRAM_DATA
Date: Mon, 19 Jan 2015 16:18:30 -0500 (EST)
Message-ID: <20150119.161830.1461440314206691151.davem@davemloft.net>
References: <1394712342-15778-126-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-126-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 19 Jan 2015 17:02:44 +0800

> Read OCP_SRAM_DATA would read additional bytes and may let
> the hw abnormal.

Series applied, thanks.
