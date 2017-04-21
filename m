From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: Remove redundant NULL dst check
Date: Fri, 21 Apr 2017 10:41:57 -0400 (EDT)
Message-ID: <20170421.104157.4939228688800987.davem@davemloft.net>
References: <20170420224723.6916-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbe@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170420224723.6916-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 20 Apr 2017 15:47:22 -0700

> tag_lan9303.c does check for a NULL dst but that's already checked by
> dsa_switch_rcv() one layer above.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thank you.
