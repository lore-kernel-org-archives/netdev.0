From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] remove bogus exports in ppp
Date: Thu, 27 Jan 2005 12:23:57 -0800
Message-ID: <20050127122357.71ad4179.davem@davemloft.net>
References: <20041024132504.GC19927@lst.de>
	<20050127112219.GA11790@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20050127112219.GA11790@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 12:22:19 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Sun, Oct 24, 2004 at 03:25:04PM +0200, Christoph Hellwig wrote:
> > even if they are usefull for debugging they're just bad namespace
> > pollution for mainline
> 
> ping?
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

I've already gotten a light slap on the hand for removing
module exports in 2.6.x, so we might want to skip on this
one.
