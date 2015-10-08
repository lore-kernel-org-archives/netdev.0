From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] net: Microchip encx24j600 driver
Date: Thu, 08 Oct 2015 04:50:56 -0700 (PDT)
Message-ID: <20151008.045056.1836119309075458337.davem@davemloft.net>
References: <1444163866-18677-1-git-send-email-jon@ringle.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: broonie@kernel.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jringle@gridpoint.com
To: jon@ringle.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444163866-18677-1-git-send-email-jon@ringle.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jon@ringle.org
Date: Tue,  6 Oct 2015 16:37:46 -0400

> From: Jon Ringle <jringle@gridpoint.com>
> 
> This ethernet driver supports the Micorchip enc424j600/626j600 Ethernet
> controller over a SPI bus interface. This driver makes use of the regmap API to
> optimize access to registers by caching registers where possible.
> 
> Datasheet:
> http://ww1.microchip.com/downloads/en/DeviceDoc/39935b.pdf
> 
> Signed-off-by: Jon Ringle <jringle@gridpoint.com>
> ---
> 
> This patch requires that the pull request from Mark be applied first:
>   git://git.kernel.org/pub/scm/linux/kernel/git/broonie/regmap.git tags/regmap-offload-update-bits

Applied, thanks Jon.
