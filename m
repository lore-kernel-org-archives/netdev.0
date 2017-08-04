From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: marvell: logical vs bitwise OR typo
Date: Fri, 4 Aug 2017 19:46:59 +0200
Message-ID: <20170804174659.GB3720@lunn.ch>
References: <20170804081720.2g6yuthplhc4rv6b@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170804081720.2g6yuthplhc4rv6b@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2017 at 11:17:21AM +0300, Dan Carpenter wrote:
> This was supposed to be a bitwise OR but there is a || vs | typo.
> 
> Fixes: 864dc729d528 ("net: phy: marvell: Refactor m88e1121 RGMII delay configuration")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Hi Dan

Thanks for the fix.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
