From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ks8851: Added support for half-duplex SPI
Date: Thu, 09 Mar 2017 18:19:03 -0800 (PST)
Message-ID: <20170309.181903.1997892032763130789.davem@davemloft.net>
References: <1489021094-12987-1-git-send-email-shchers@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        tremyfr@gmail.com, stephen.boyd@linaro.org, jarod@redhat.com
To: shchers@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489021094-12987-1-git-send-email-shchers@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergey Shcherbakov <shchers@gmail.com>
Date: Thu,  9 Mar 2017 02:58:14 +0200

> In original driver was implemented support for half-
> and full-duplex modes, but it was not enabled. Instead
> of it ks8851_rx_1msg method always returns "true" that
> means "full-duplex" mode.
> 
> This patch replaces hard-coded functionality with
> flexible solution that supports both SPI modes.
> 
> Signed-off-by: Sergey Shcherbakov <shchers@gmail.com>

Applied.
