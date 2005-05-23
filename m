From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Why /sys/class/net/*/features is read-only?
Date: Mon, 23 May 2005 14:51:12 -0700 (PDT)
Message-ID: <20050523.145112.78711028.davem@davemloft.net>
References: <Pine.LNX.4.62.0505232346310.17855@webhosting.rdsbv.ro>
	<20050523.135348.55831423.davem@davemloft.net>
	<Pine.LNX.4.62.0505240032480.17855@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: util@deuroconsult.ro
In-Reply-To: <Pine.LNX.4.62.0505240032480.17855@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Date: Tue, 24 May 2005 00:33:14 +0300 (EEST)

> On Mon, 23 May 2005, David S. Miller wrote:
> 
> > Let them use ethtool :-)
> 
> They can't on a bridge device, right?

Currently no.  But there is no reason the bridge device
should not have ethtool support added to it, and that's
where this functionality belongs.
