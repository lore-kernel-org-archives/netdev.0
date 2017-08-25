From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net v2 1/4] net: mvpp2: fix the mac address used when
 using PPv2.2
Date: Fri, 25 Aug 2017 17:42:47 +0200
Message-ID: <20170825154247.GC30922@lunn.ch>
References: <20170825141420.14027-1-antoine.tenart@free-electrons.com>
 <20170825141420.14027-2-antoine.tenart@free-electrons.com>
 <20170825141939.GB30922@lunn.ch>
 <20170825142928.GB31512@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825142928.GB31512@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So probably the best way to handle this would have been to send 1/4 to
> net and 2-4/4 to net-next

Correct. 

> (but then there's a dependency between the two series).

Dave merges net into net-next every so often. So you just need to wait
a bit before submitting the net-next parts.

  Andrew
