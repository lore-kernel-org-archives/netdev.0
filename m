From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/13] macsonic: fix crash on PowerBook 520
Date: Fri, 06 Nov 2009 20:27:06 -0800 (PST)
Message-ID: <20091106.202706.136677578.davem@davemloft.net>
References: <alpine.OSX.2.00.0911031448060.483@silk.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, tsbogend@alpha.franken.de,
	netdev@vger.kernel.org, linux-m68k@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.OSX.2.00.0911031448060.483@silk.local>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Wed, 4 Nov 2009 00:42:40 +1100 (EST)

> No-one seems to know where the PowerBook 500 series store their ethernet 
> MAC addresses. So, rather than crash, use a MAC address from the SONIC 
> CAM. Failing that, generate a random one.
> 
> Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

Applied to net-2.6
