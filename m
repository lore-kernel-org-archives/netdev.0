From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.7 oops, sk98lin related?
Date: Thu, 22 Jul 2004 16:03:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722150314.GB13195@infradead.org>
References: <200407221101.16388.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bernd Schubert <bernd-schubert@web.de>
Content-Disposition: inline
In-Reply-To: <200407221101.16388.bernd-schubert@web.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 22, 2004 at 11:01:14AM +0200, Bernd Schubert wrote:
> Hello Christoph and all others,
> 
> is this an sk98lin oops, maybe related to your patches or is it a completely 
> different problem?

I don't think there's skge patches from me in 2.6.7 yet, but certainly not
in that area ;-)

This is just a big memory allocation failing, not an oops anyway.
