From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2012-09-21
Date: Fri, 21 Sep 2012 13:51:00 -0400 (EDT)
Message-ID: <20120921.135100.2021015240286558305.davem@davemloft.net>
References: <1348225535-24976-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1348225535-24976-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 21 Sep 2012 13:05:33 +0200

> two patches for the v3.6 release cycle. Ira W. Snyder fixed support for the
> older version of the Janz CMOD-IO Carrier Board. I found and fixed an oops in
> the ti_hecc driver, which occurs when removing the module if the network
> interface is still open.
 ...
> The following changes since commit c0d680e577ff171e7b37dbdb1b1bf5451e851f04:
> 
>   net: do not disable sg for packets requiring no checksum (2012-09-20 22:23:40 -0400)
> 
> are available in the git repository at:
> 
>   git://gitorious.org/linux-can/linux-can.git fixes-for-3.6

Pulled, thanks.
