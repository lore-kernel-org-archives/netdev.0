From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 2.6.12-rc5] tg3: add bcm5752 entry to pci.ids
Date: Fri, 27 May 2005 13:41:03 -0700 (PDT)
Message-ID: <20050527.134103.10293460.davem@davemloft.net>
References: <20050527.123037.68041200.davem@davemloft.net>
	<1117221859.4310.6.camel@rh4>
	<429785B5.6020705@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, linville@tuxdriver.com, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <429785B5.6020705@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Fri, 27 May 2005 16:40:21 -0400

> pci.ids is only used in one location -- deprecated /proc/pci -- and will 
> be removed in the next year or so, I imagine. Further, pci.ids is 
> periodically sync'd en masse from sourceforge into the kernel by janitors.

Good point.
