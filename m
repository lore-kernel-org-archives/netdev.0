From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: marvell: logical vs bitwise OR typo
Date: Fri, 04 Aug 2017 10:57:03 -0700 (PDT)
Message-ID: <20170804.105703.352607975740407803.davem@davemloft.net>
References: <20170804081720.2g6yuthplhc4rv6b@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170804081720.2g6yuthplhc4rv6b@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 4 Aug 2017 11:17:21 +0300

> This was supposed to be a bitwise OR but there is a || vs | typo.
> 
> Fixes: 864dc729d528 ("net: phy: marvell: Refactor m88e1121 RGMII delay configuration")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, but please specify "[PATCH net-next]" in your Subject line
and make your target tree explicit in the future.

Thanks.
