From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] netif_rx: receive path optimization
Date: 30 Mar 2005 17:08:24 -0500
Message-ID: <1112220504.1075.96.camel@jzny.localdomain>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
	 <1112219848.1078.93.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <1112219848.1078.93.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-30 at 16:57, jamal wrote:

> Like discussed in that thread with person who enhanced the SACK queue
> traversal that for a serious use a TCP user really oughta migrate to a
> NAPI driver. 
> 

I think i wasnt clear:
The change is fine - just saying that someone serious about benchmarky
numbers should probably not use that interface.

cheers,
jamal
