From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: OT: randomly unsubscribed
Date: Fri, 4 Jun 2004 19:12:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040604171225.GB15486@linux-mips.org>
References: <Pine.NEB.4.33.0406040858260.4315-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
Content-Disposition: inline
In-Reply-To: <Pine.NEB.4.33.0406040858260.4315-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 04, 2004 at 09:04:40AM -0400, John Heffner wrote:

> I can't find an admin address for this list, sorry about the off-topic
> post.

Ever heared about postmaster?

> I'm getting randomly and silently unsubscribed from this list.  It's
> happened three or four times now in the past few months.  Could the list
> admin look in to this?

Subscribers will be unsubscribed if a there the number of bounces exceeds
a certain threshold.  The bounce filter is not able to distinguish between
"real" bounces and false bounces such caused by sender address forgery
by viruses and spam.  As you can imagine due the massive abuse of email
by spam and viruses this is going to cause problems ...  For now I've
double the number of bounces before a user gets unsubscribed.

  Ralf
