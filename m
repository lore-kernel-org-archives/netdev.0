From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] remove net_init.c ifdef clutter
Date: Thu, 11 Nov 2004 14:50:58 -0800
Message-ID: <20041111145058.0fc24412.davem@davemloft.net>
References: <20041101130144.GA8727@lst.de>
	<20041110165641.GA29705@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20041110165641.GA29705@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Nov 2004 17:56:42 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Mon, Nov 01, 2004 at 02:01:44PM +0100, Christoph Hellwig wrote:
> > Move the devicetype-specific functions from net_init.c to the
> > devicetype-specific files under net/.
> 
> ping?  still applies fine against current BK.

Applied, thanks Christoph.
