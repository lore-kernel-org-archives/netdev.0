From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] net: mvneta: fix error messages in
 mvneta_port_down function
Date: Fri, 11 Mar 2016 14:20:22 -0500 (EST)
Message-ID: <20160311.142022.1421480365252928267.davem@davemloft.net>
References: <1457441826-6100-1-git-send-email-gregory.clement@free-electrons.com>
	<1457441826-6100-4-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, jason@lakedaemon.net,
	andrew@lunn.ch, sebastian.hesselbarth@gmail.com,
	linux-arm-kernel@lists.infradead.org, alior@marvell.com,
	nadavh@marvell.com, mw@semihalf.com, patrick@puiterwijk.org,
	dima@marvell.com, oferh@marvell.com
To: gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457441826-6100-4-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Date: Tue,  8 Mar 2016 13:57:06 +0100

> From: Dmitri Epshtein <dima@marvell.com>
> 
> This commit corrects error printing when shutting down the port. Also
> magic numbers are replaced by existing macros.
> 
> Signed-off-by: Dmitri Epshtein <dima@marvell.com>
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Individual patches should do one thing, rather than several at once.

Please split this up into two changes, thanks.
