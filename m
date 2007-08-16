From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 18:14:26 -0700
Message-ID: <20070816011426.GD9645@linux.vnet.ibm.com>
References: <20070815142516.GB9645@linux.vnet.ibm.com> <4413.1187201997@redhat.com> <20070815184520.GG9645@linux.vnet.ibm.com> <20070815234146.GB28775@gondor.apana.org.au> <20070815235335.GU9645@linux.vnet.ibm.com> <20070816001248.GA29214@gondor.apana.org.au> <20070816002310.GW9645@linux.vnet.ibm.com> <20070816003023.GA29447@gondor.apana.org.au> <20070816004950.GZ9645@linux.vnet.ibm.com> <20070816005316.GA29802@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Howells <dhowells@redhat.com>,
	Satyam Sharma <satyam@infradead.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Herbert Xu <herbert.xu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:56932 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936289AbXHPBOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 21:14:30 -0400
Content-Disposition: inline
In-Reply-To: <20070816005316.GA29802@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 08:53:16AM +0800, Herbert Xu wrote:
> On Wed, Aug 15, 2007 at 05:49:50PM -0700, Paul E. McKenney wrote:
> > On Thu, Aug 16, 2007 at 08:30:23AM +0800, Herbert Xu wrote:
> >
> > > Thanks.  But I don't need a summary of the thread, I'm asking
> > > for an extant code snippet in our kernel that benefits from
> > > the volatile change and is not part of a busy-wait.
> > 
> > Sorry, can't help you there.  I really do believe that the information
> > you need (as opposed to the specific item you are asking for) really
> > has been put forth in this thread.
> 
> That only leads me to believe that such a code snippet simply
> does not exist.

Whatever...

						Thanx, Paul
