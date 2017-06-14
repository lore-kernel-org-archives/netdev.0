From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Wed, 14 Jun 2017 03:37:50 +0200
Message-ID: <20170614013750.GG23384@lunn.ch>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-3-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170613231035.494020-3-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 14, 2017 at 12:10:29AM +0100, Salil Mehta wrote:
> +static int __init hnae3_init(void)
> +{
> +	return 0;
> +}
> +

..

> +subsys_initcall(hnae3_init);

And the point of this is?

    Andrew
