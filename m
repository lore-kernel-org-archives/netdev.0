From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Ethernet Bridging: Enable Hardware Checksumming
Date: Thu, 19 May 2005 16:36:27 -0700 (PDT)
Message-ID: <20050519.163627.92582487.davem@davemloft.net>
References: <20050519133333.07a992e6@dxpl.pdx.osdl.net>
	<20050519.144800.71090042.davem@davemloft.net>
	<200505191823.31777.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jdmason@us.ibm.com
In-Reply-To: <200505191823.31777.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jon Mason <jdmason@us.ibm.com>
Date: Thu, 19 May 2005 18:23:31 -0500

> Since NETIF_F_HW_CSUM encompasses NETIF_F_IP_CSUM, perhaps it would
> be better to use the latter until such time as a new infrastructure
> can be implimented.

Probably, that is the best idea, it is again another
definition of "subset".
