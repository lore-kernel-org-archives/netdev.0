From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] remove dead exports from net/core/dev.c
Date: Tue, 9 Nov 2004 16:23:25 -0800
Message-ID: <20041109162325.18d2e282.davem@davemloft.net>
References: <20041101114605.GA7507@lst.de>
	<20041106174307.GA19806@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20041106174307.GA19806@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 6 Nov 2004 18:43:07 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Mon, Nov 01, 2004 at 12:46:05PM +0100, Christoph Hellwig wrote:
> > this also allows to kill some competely dead code, e.g. many of the
> > non-locked __foo routines.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> rediffed against current BK:

Applied, thanks Christoph.
