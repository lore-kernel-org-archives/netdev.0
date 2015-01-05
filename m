From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qlcnic: Fix dump_skb output
Date: Sun, 04 Jan 2015 22:24:48 -0500 (EST)
Message-ID: <20150104.222448.2069931734048612119.davem@davemloft.net>
References: <1420336216.2619.9.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420336216.2619.9.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 03 Jan 2015 17:50:16 -0800

> Use normal facilities to avoid printing each byte
> on a separate line.
> 
> Now emits at KERN_DEBUG instead of KERN_INFO.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

This looks fine, applied, thanks Joe.
