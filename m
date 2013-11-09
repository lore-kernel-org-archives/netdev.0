From: David Miller <davem@davemloft.net>
Subject: Re: xen-netback stable backport requests
Date: Sat, 09 Nov 2013 15:56:13 -0500 (EST)
Message-ID: <20131109.155613.787148078862725586.davem@davemloft.net>
References: <1383826530.32399.13.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1383826530.32399.13.camel@kazak.uk.xensource.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Thu, 7 Nov 2013 12:15:30 +0000

> 279f438e36c0 "xen-netback: Don't destroy the netdev until the vif is
> shut down" has hit stable but unfortunately is causing regressions. 
> 
> This should be fixed by dc62ccaccfb1 "xen-netback: transition to CLOSED
> when removing a VIF" which depends on ea732dff5cfa "xen-netback: Handle
> backend state transitions in a more robust way".
> 
> Please could you queue hose two for stable.

Queued up for 3.10 and 3.11 -stable, thanks!
