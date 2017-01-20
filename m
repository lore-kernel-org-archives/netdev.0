From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: fix rtl8152_post_reset function
Date: Fri, 20 Jan 2017 11:06:39 -0500 (EST)
Message-ID: <20170120.110639.1752899687593550120.davem@davemloft.net>
References: <1394712342-15778-233-Taiwan-albertk@realtek.com>
        <1394712342-15778-234-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-234-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 20 Jan 2017 14:33:55 +0800

> The rtl8152_post_reset() should sumbit rx urb and interrupt transfer,
> otherwise the rx wouldn't work and the linking change couldn't be
> detected.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thank you.
