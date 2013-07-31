From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/5] net/usb/r815x: replace USB buffer from stack to
 DMA-able
Date: Wed, 31 Jul 2013 14:49:42 -0700 (PDT)
Message-ID: <20130731.144942.401149773722757855.davem@davemloft.net>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
	<1375262486-5373-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375262486-5373-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 31 Jul 2013 17:21:22 +0800

> Some USB buffers use stack which may not be DMA-able.
> Use the buffers from kmalloc to replace those one.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
