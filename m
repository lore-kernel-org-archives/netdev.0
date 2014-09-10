From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: use usleep_range
Date: Tue, 09 Sep 2014 20:11:29 -0700 (PDT)
Message-ID: <20140909.201129.274222387243042834.davem@davemloft.net>
References: <1394712342-15778-35-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-35-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 9 Sep 2014 11:40:28 +0800

> Replace mdelay with usleep_range to avoid busy loop.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
