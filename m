From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Intel and TOE in the news
Date: Sat, 19 Feb 2005 21:32:04 +0100
Message-ID: <20050219203204.GB21315@xi.wantstofly.org>
References: <4216B62D.6000502@pobox.com> <20050219041007.GA17896@xi.wantstofly.org> <20050219114624.373af63f.davem@davemloft.net> <m1psywb8i4.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        netdev@oss.sgi.com
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <m1psywb8i4.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 19, 2005 at 09:27:31PM +0100, Andi Kleen wrote:

> It would be nice if the NIC could asynchronously trigger prefetches
> in the CPU. Currently a lot of the packet processing cost goes to
> waiting for read cache misses.

I've been told that this is something that the BCM-1250 can do.
The MACs are in the CPU, and they can (reportedly) DMA the packet
headers straight into L2.


--L
