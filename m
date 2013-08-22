From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: mdio-octeon: use platform_set_drvdata()
Date: Wed, 21 Aug 2013 20:51:48 -0700 (PDT)
Message-ID: <20130821.205148.804691292072117400.davem@davemloft.net>
References: <1377080115-58636-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, rob.herring@calxeda.com,
	david.daney@cavium.com, wfp5p@virginia.edu,
	gregkh@linuxfoundation.org, sachin.kamat@linaro.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lizefan@huawei.com
To: libo.chen@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377080115-58636-1-git-send-email-libo.chen@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Libo Chen <libo.chen@huawei.com>
Date: Wed, 21 Aug 2013 18:15:15 +0800

> Use the wrapper functions for getting and setting the driver data using
> platform_device instead of using dev_set_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.
> 
> Signed-off-by: Libo Chen <libo.chen@huawei.com>

Applied.
