From: Roger Luethi <rl@hellgate.ch>
Subject: Re: via-rhine "reset did not complete" errors
Date: Tue, 29 Oct 2002 17:35:16 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021029163516.GC3714@k3.hellgate.ch>
References: <7BFCE5F1EF28D64198522688F5449D5A03C079@xchangeserver2.storigen.com> <Pine.LNX.4.44.0210281425480.1346-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Sendlosky <Larry.Sendlosky@storigen.com>, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0210281425480.1346-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Oct 2002 14:38:18 -0500, Donald Becker wrote:
> On Mon, 28 Oct 2002, Larry Sendlosky wrote:
> 
> > We're using VIA EPIA mini-ITX with 800Mhz C3 and the
> > VT6103 PHY. (via-rhine driver says VT6102). We have made sure
> > power supply is "big enough". Our kernel is 2.4.18 with
> > via-rhine.c patches to fix TX timeout.
> 
> Those are evil patches...

Care to elaborate? Since I wrote the patch to fix the Tx timeout issue, I'd
be very interested to learn how exactly it is evil.

Roger
