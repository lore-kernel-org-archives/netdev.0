From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 14/27] net: mvpp2: add ip_version field in
 "struct mvpp2"
Date: Wed, 21 Dec 2016 18:02:52 +0100
Message-ID: <20161221170252.GO30952@lunn.ch>
References: <1482318994-23488-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482318994-23488-15-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Hanna Hawa <hannah@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        linux-arm-kernel@lists.infradead.org,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34166 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754208AbcLURDj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Dec 2016 12:03:39 -0500
Content-Disposition: inline
In-Reply-To: <1482318994-23488-15-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas

Minor nit pick.

On Wed, Dec 21, 2016 at 12:16:21PM +0100, Thomas Petazzoni wrote:
> In preparation to the introduction for the support of PPv2.2 in the
> mvpp2 driver, this commit adds an ip_version field to the struct
> mvpp2

When i read this, i was thinking IPv4 vs IPv6. It is a network driver after all.
Could you maybe call this hw_version?

Thanks
	Andrew
