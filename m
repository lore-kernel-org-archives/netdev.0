From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] firewire net: Ensure checksumming in upper layer.
Date: Sun, 20 Jan 2013 23:16:30 -0500 (EST)
Message-ID: <20130120.231630.1756371720847819355.davem@davemloft.net>
References: <50FBA02C.9030203@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50FBA02C.9030203@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sun, 20 Jan 2013 16:43:40 +0900

> It is wrong to set skb->ip_summed to CHECKSUM_UNNECESSARY unless
> the device has already checked it.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
