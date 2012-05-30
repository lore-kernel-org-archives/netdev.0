From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8021q/vlan: process NETDEV_GOING_DOWN
Date: Wed, 30 May 2012 16:27:51 -0400 (EDT)
Message-ID: <20120530.162751.80640634568619332.davem@davemloft.net>
References: <1338330635-27259-1-git-send-email-eldad@fogrefinery.com>
	<20120529.204040.644013889059321702.davem@davemloft.net>
	<alpine.DEB.2.02.1205302055140.1587@debianer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1205302055140.1587@debianer>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eldad Zack <eldad@fogrefinery.com>
Date: Wed, 30 May 2012 21:11:02 +0200 (CEST)

> In case a certain protocol needs to send a "dying gasp" packet, when you 
> administrativly shutdown the port (which is also what happens when you 
> restart the machine).

No in tree users have this requirement, therefore your patch is
inappropriate.
