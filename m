From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 0/3] net-next: dsa: add QCA8K support
Date: Fri, 16 Sep 2016 04:32:17 -0400 (EDT)
Message-ID: <20160916.043217.519059245886845420.davem@davemloft.net>
References: <1473949601-20674-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, qsdk-review@qca.qualcomm.com
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473949601-20674-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Thu, 15 Sep 2016 16:26:38 +0200

> This series is based on the AR8xxx series posted by Matthieu Olivari in may
> 2015. The following changes were made since then
> 
> * fixed the nitpicks from the previous review
> * updated to latest API
> * turned it into an mdio device
> * added callbacks for fdb, bridge offloading, stp, eee, port status
> * fixed several minor issues to the port setup and arp learning
> * changed the namespacing as this driver to qca8k
> 
> The driver has so far only been tested on qca8337/N. It should work on other QCA
> switches such as the qca8327 with minor changes.

Series applied.
