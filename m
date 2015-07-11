From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Drop owner assignment from platform_driver
Date: Fri, 10 Jul 2015 23:18:42 -0700 (PDT)
Message-ID: <20150710.231842.1899405994565422319.davem@davemloft.net>
References: <1436509763-23980-1-git-send-email-k.kozlowski@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, m-karicheri2@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: k.kozlowski@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436509763-23980-1-git-send-email-k.kozlowski@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Fri, 10 Jul 2015 15:29:23 +0900

> platform_driver does not need to set an owner because
> platform_driver_register() will set it.
> 
> Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>

Applied to net-next, thanks.
