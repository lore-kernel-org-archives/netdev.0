From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 4/5] net/usb/r8152: make sure the USB buffer is
 DMA-able
Date: Wed, 31 Jul 2013 14:50:03 -0700 (PDT)
Message-ID: <20130731.145003.232571872024474569.davem@davemloft.net>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
	<1375262486-5373-1-git-send-email-hayeswang@realtek.com>
	<1375262486-5373-4-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375262486-5373-4-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 31 Jul 2013 17:21:25 +0800

> Allocate the required memory before calling usb_control_msg. And
> the additional memory copy is necessary.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
