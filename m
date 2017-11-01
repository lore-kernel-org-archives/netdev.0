From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: b53: Have b53_hdr_setup()
 enable/disable tagging
Date: Wed, 01 Nov 2017 20:51:55 +0900 (KST)
Message-ID: <20171101.205155.1491105017521642364.davem@davemloft.net>
References: <20171030221721.31757-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171030221721.31757-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 30 Oct 2017 15:17:20 -0700

> Have b53_hdr_setup() check what kind of tagging protocol is configured
> (Broadcom or none) and apply the correct settings in both cases.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
