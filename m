From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 8/8] net: davinci_mdio: use platform_{get,set}_drvdata()
Date: Mon, 12 Aug 2013 22:23:02 +0530
Message-ID: <520912EE.1080202@ti.com>
References: <5208E231.60104@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <bigeasy@linutronix.de>,
	<prabhakar.csengg@gmail.com>, <b-liu@ti.com>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: Libo Chen <clbchenlibo.chen@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5208E231.60104@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 12 August 2013 06:55 PM, Libo Chen wrote:
> Use the wrapper functions for getting and setting the driver data using
> platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.
>
> Signed-off-by: Libo Chen <libo.chen@huawei.com>
Looks good.
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
