From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: check master device before put
Date: Wed, 25 Oct 2017 10:49:49 +0900 (KST)
Message-ID: <20171025.104949.70836310681253404.davem@davemloft.net>
References: <20171024203719.25183-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024203719.25183-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 24 Oct 2017 16:37:19 -0400

> In the case of pdata, the dsa_cpu_parse function calls dev_put() before
> making sure it isn't NULL. Fix this.
> 
> Fixes: 71e0bbde0d88 ("net: dsa: Add support for platform data")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable.

Thank you.
