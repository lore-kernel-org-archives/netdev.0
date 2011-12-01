From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next 0/2] can: cc770: add support for the Bosch
 CC770 and Intel AN82527
Date: Thu, 01 Dec 2011 13:09:07 -0500 (EST)
Message-ID: <20111201.130907.1276930495409347261.davem@davemloft.net>
References: <4ED5CF14.4020502@hartkopp.net>
	<20111130.160727.1989923062226789802.davem@davemloft.net>
	<4ED73117.1020101@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, mkl@pengutronix.de,
	urs@isnogud.escape.de
To: socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4ED73117.1020101@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Thu, 01 Dec 2011 08:47:35 +0100

> On 30.11.2011 22:07, David Miller wrote:
> 
> To make it clear:
> 
> 	Wolfgang Grandegger maintains drivers/net/can
> 
> and
> 
> 	Oliver Hartkopp maintains net/can
> 
> As Marc Kleine-Budde is also very active in CAN driver development we should
> probably add him to the drivers/net/can maintainers.
> 
> We'll continue the discussion on linux-can ML and give an update to the
> MAINTAINERS file if we sorted out any changes. So far Wolfgang and me remain
> the 'only interface' for you. Sorry for the traffic & confusion on netdev.

I said I want one person.  One person who periodically send me GIT pull requests
or a patch series for "CAN updates" of all kinds.

Just like how the wireless stuff is maintained.  They don't send me driver vs.
protcol layer vs. rfcomm vs. bluetooth changes seperately, John Linville collects
everything and sends me periodic pull requests.

And this is what I want from you guys.  One person who explicitly says "Dave, please
take in these CAN changes" rather than the confusing manner in which changes get
submitted currently.

Thanks.

