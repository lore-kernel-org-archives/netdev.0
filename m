From: Larry McVoy <lm@bitmover.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Fri, 27 Jun 2003 17:19:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030628001954.GD18676@work.bitmover.com>
References: <3EFCC1EB.2070904@candelatech.com> <20030627.151906.102571486.davem@redhat.com> <3EFCC6EE.3020106@candelatech.com> <20030627.170022.74744550.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, davidel@xmailserver.org, mbligh@aracnet.com,
   linux-kernel@vger.kernel.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030627.170022.74744550.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 27, 2003 at 05:00:22PM -0700, David S. Miller wrote:
>    From: Ben Greear <greearb@candelatech.com>
>    Date: Fri, 27 Jun 2003 15:36:30 -0700
>    
>    So, you'd be happy so long as bugz sent mail to the netdev mailing
>    lists instead of to you?
> 
> The best power I have to scale is the delete key in my email
> reader, when I delete an email it's gone and that's it.
> 
> bugme bugs don't have this attribute, they are like emails that
> persist forever until someone does something about them, and this is
> the big problem I have with it.

I've proposed this before and nobody listened but maybe this time...

I think what you want is a bug database which distinguishes between
filed bugs and reviewed bugs.  You want to capture all bug reports, 
as Alan says (he's right, there is no question about it, you need to
capture the data).  You also want an *automatic* way for bugs to just
rot.  Anyone can file a bug but unless someone with expertise in the 
area reviews the bug and agrees to do something about it, the bug rots.

It's level 1 (capture) and level 2 (we really need to do something about
this some day).  Level 1 will have zillions of duplicates and tons of 
other noise.  Level 2 should be a small list, no duplicates, carefully
managed.
-- 
---
Larry McVoy              lm at bitmover.com          http://www.bitmover.com/lm
