From: "David S. Miller" <davem@redhat.com>
Subject: Re: patricia tries vs. hash for routing?
Date: Fri, 19 Sep 2003 23:37:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919233730.75969de6.davem@redhat.com>
References: <20030919214837.GA3012@sirius.cs.pdx.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kristen Carlson <kristenc@cs.pdx.edu>
In-Reply-To: <20030919214837.GA3012@sirius.cs.pdx.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 19 Sep 2003 14:48:37 -0700
Kristen Carlson <kristenc@cs.pdx.edu> wrote:

> I was looking through some very old mail list discussions (1996!) on this 
> topic, and the feeling then was that the code was optimal for < 60,000 routes.
> Given that much has happened since then, is it still a fair assumption to say
> that the linux routing algorithm is optimized for < 60,000 routes, but a
> more BSD-like algorithm works better for > 60,000 routes?

That's not true at all, the current code can handle many more than
60,000 routes.

Don't speak with abstract claims that bear no content, do your own
experiments with a properly configured system and report them in
detail here.
