From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ravb: remove unhandle int cause
Date: Mon, 16 Nov 2015 15:12:42 -0500 (EST)
Message-ID: <20151116.151242.944204466671951295.davem@davemloft.net>
References: <1447590882-20742-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au, magnus.damm@gmail.com,
	linux-sh@vger.kernel.org
To: ykaneko0929@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1447590882-20742-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Date: Sun, 15 Nov 2015 21:34:42 +0900

> From: Masaru Nagai <masaru.nagai.vx@renesas.com>
> 
> This driver does not handle the AVB-DMAC Receive FIFO Warning interrupt
> now, so the interrupt should not be enabled.
> 
> Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

Applied, thanks.
