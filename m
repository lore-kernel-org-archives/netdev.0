From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v3 7/7] net: davinci_mdio: use platform_{get,set}_drvdata()
Date: Sat, 17 Aug 2013 17:21:57 +0530
Message-ID: <520F63DD.8070607@ti.com>
References: <520CD13E.7090802@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <bigeasy@linutronix.de>,
	<prabhakar.csengg@gmail.com>, <b-liu@ti.com>,
	<netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Libo Chen <clbchenlibo.chen@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <520CD13E.7090802@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 15 August 2013 06:31 PM, Libo Chen wrote:
> Use the wrapper functions for getting and setting the driver data using
> platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.
>
> Signed-off-by: Libo Chen <libo.chen@huawei.com>
I had given my ack for your previous version itself, I don't know why
you didn't add my Ack in next version.
Any how

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
