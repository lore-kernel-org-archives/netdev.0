From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: irda: pxaficp_ir: use platform_set_drvdata()
Date: Wed, 21 Aug 2013 20:51:43 -0700 (PDT)
Message-ID: <20130821.205143.2287137631612127980.davem@davemloft.net>
References: <1377080111-11348-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, lizefan@huawei.com
To: libo.chen@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377080111-11348-1-git-send-email-libo.chen@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Libo Chen <libo.chen@huawei.com>
Date: Wed, 21 Aug 2013 18:15:11 +0800

> Use the wrapper functions for getting and setting the driver data using
> platform_device instead of using deva_set_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.
> 
> Signed-off-by: Libo Chen <libo.chen@huawei.com>

Applied.
