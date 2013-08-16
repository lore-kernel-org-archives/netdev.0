From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH v3 7/7] net: davinci_mdio: use platform_{get,set}_drvdata()
Date: Fri, 16 Aug 2013 22:45:03 +0530
Message-ID: <CA+V-a8vgOWzu9d-kfw4Qp5N7AU3p=Jb8tGmak4aRNq49WKpJdA@mail.gmail.com>
References: <520CD13E.7090802@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>, bigeasy@linutronix.de,
	b-liu@ti.com, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Libo Chen <clbchenlibo.chen@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <520CD13E.7090802@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 15, 2013 at 6:31 PM, Libo Chen <clbchenlibo.chen@huawei.com> wrote:
> Use the wrapper functions for getting and setting the driver data using
> platform_device instead of using dev_{get,set}_drvdata() with &pdev->dev,
> so we can directly pass a struct platform_device.
>
> Signed-off-by: Libo Chen <libo.chen@huawei.com>

Acked-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Regards,
--Prabhakar Lad
