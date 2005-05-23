From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Why /sys/class/net/*/features is read-only?
Date: Mon, 23 May 2005 13:53:48 -0700 (PDT)
Message-ID: <20050523.135348.55831423.davem@davemloft.net>
References: <Pine.LNX.4.62.0505201346420.29305@webhosting.rdsbv.ro>
	<20050523092827.7883af33@dxpl.pdx.osdl.net>
	<Pine.LNX.4.62.0505232346310.17855@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: util@deuroconsult.ro
In-Reply-To: <Pine.LNX.4.62.0505232346310.17855@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Date: Mon, 23 May 2005 23:49:57 +0300 (EEST)

> If you have a bridge with 5 net cards and 4 supports SG, some people 
> may want to force SG on the bridge.

Let them use ethtool :-)
