From: Martin Pool <mbp@samba.org>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Tue, 8 Oct 2002 20:21:38 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021008102137.GA10627@toey.sourcefrog.net>
References: <20021005075157.GC2531@samba.org> <Mutt.LNX.4.44.0210052152400.25151-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
Content-Disposition: inline
In-Reply-To: <Mutt.LNX.4.44.0210052152400.25151-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On  5 Oct 2002, James Morris <jmorris@intercode.com.au> wrote:

> > I can't reproduce it locally, but I can reproduce it going to a 2.4.18
> > machine across a 100Mbps switched network.  A tcpdump (complete?) is
> > attached.
> 
> Thanks for the extra info.

OK, let me know if there's anything else you need.  At a stretch I
could install 2.2 on a non-VM machine.

-- 
Martin                                                   Discontent Provider
