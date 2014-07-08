From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: increase the tx timeout
Date: Tue, 08 Jul 2014 11:32:02 -0700 (PDT)
Message-ID: <20140708.113202.326542398099281937.davem@davemloft.net>
References: <1404359748-4202-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404359748-4202-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 3 Jul 2014 11:55:48 +0800

> When the system is too busy to complete the urb, the tx timout function
> would be called. This causes the other tx urbs would be killed, too.
> Increase the tx timeout to avoid it.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thank you.
