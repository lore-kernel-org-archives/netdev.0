From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hinic: uninitialized variable in
 hinic_api_cmd_init()
Date: Thu, 24 Aug 2017 21:48:34 -0700 (PDT)
Message-ID: <20170824.214834.959375646627489858.davem@davemloft.net>
References: <20170824104739.gw422ufydwmiu4gi@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aviad.krawczyk@huawei.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170824104739.gw422ufydwmiu4gi@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 24 Aug 2017 13:47:39 +0300

> We never set the error code in this function.
> 
> Fixes: eabf0fad81d5 ("net-next/hinic: Initialize api cmd resources")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
