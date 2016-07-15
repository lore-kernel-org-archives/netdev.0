From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net: ethernet: ethoc: use
 phy_ethtool_{get|set}_link_ksettings
Date: Fri, 15 Jul 2016 16:43:42 -0700 (PDT)
Message-ID: <20160715.164342.514938476331897717.davem@davemloft.net>
References: <1468569552-24824-1-git-send-email-tremyfr@gmail.com>
	<1468569552-24824-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, tklauser@distanz.ch, colin.king@canonical.com,
	f.fainelli@gmail.com, jcmvbkbc@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468569552-24824-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Fri, 15 Jul 2016 09:59:12 +0200

> There are two generics functions phy_ethtool_{get|set}_link_ksettings,
> so we can use them instead of defining the same code in the driver.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
