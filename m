From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH 7/8] net: davinci_mdio: remove unnecessary dev_set_drvdata()
Date: Thu, 22 Aug 2013 11:23:44 +0530
Message-ID: <CA+V-a8v7_ZdX4FSeEdgq1tFxjDVNW9+LGbQm8YrVhXchXkWxdw@mail.gmail.com>
References: <1377068561-15744-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>, bigeasy@linutronix.de,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Li Zefan <lizefan@huawei.com>
To: Libo Chen <libo.chen@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377068561-15744-1-git-send-email-libo.chen@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Libo,

Thanks for the patch.

On Wed, Aug 21, 2013 at 12:32 PM, Libo Chen <libo.chen@huawei.com> wrote:
> Unnecessary dev_set_drvdata() is removed, because the driver core
> clears the driver data to NULL after device_release or on probe failure.
>
> Signed-off-by: Libo Chen <libo.chen@huawei.com>

Acked-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Regards,
--Prabhakar Lad
