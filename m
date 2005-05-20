From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Notifier for features change? (related to Ethernet Bridging:
 Enable Hardware Checksumming)
Date: Fri, 20 May 2005 11:10:40 -0700 (PDT)
Message-ID: <20050520.111040.97294719.davem@davemloft.net>
References: <Pine.LNX.4.62.0505201014340.12681@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: util@deuroconsult.ro
In-Reply-To: <Pine.LNX.4.62.0505201014340.12681@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Date: Fri, 20 May 2005 10:17:46 +0300 (EEST)

> Because bridge can change features based on slaves features,
> may I implement NETDEV_FEAT_CHANGE?
> 
> It will be used to recompute bridge features when a slave ones are 
> changed.

Please do.
