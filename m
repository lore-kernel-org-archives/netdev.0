From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] cx82310_eth: check usb_string() return
 value for error
Date: Mon, 13 Sep 2010 20:04:07 -0700 (PDT)
Message-ID: <20100913.200407.242136382.davem@davemloft.net>
References: <201009111740.00243.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009111740.00243.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ondrej Zary <linux@rainbow-software.org>
Date: Sat, 11 Sep 2010 17:39:57 +0200

> Fix that usb_string() return value is not checked for error (negative value).
> Also change the ignore message a bit and lower its level to info.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

Applied.
