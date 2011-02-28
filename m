From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/fec: fix unterminated platform_device_id table
Date: Mon, 28 Feb 2011 12:36:00 -0800 (PST)
Message-ID: <20110228.123600.179929985.davem@davemloft.net>
References: <1298453244.25444.1.camel@mola>
	<1298453326.25444.3.camel@mola>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, u.kleine-koenig@pengutronix.de,
	netdev@vger.kernel.org
To: axel.lin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298453326.25444.3.camel@mola>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Axel Lin <axel.lin@gmail.com>
Date: Wed, 23 Feb 2011 17:28:46 +0800

> The platform_device_id table is supposed to be zero-terminated.
> 
> Signed-off-by: Axel Lin <axel.lin@gmail.com>

Applied, thanks.
