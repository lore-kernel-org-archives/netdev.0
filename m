From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: rename rx_buf_sz
Date: Mon, 01 Sep 2014 20:42:32 -0700 (PDT)
Message-ID: <20140901.204232.1824043953151511854.davem@davemloft.net>
References: <1394712342-15778-25-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-25-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 2 Sep 2014 10:27:52 +0800

> The variable "rx_buf_sz" is used by both tx and rx buffers. Replace
> it with "agg_buf_sz".
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
