From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] TSO Reloaded
Date: Thu, 5 May 2005 16:14:39 -0700
Message-ID: <20050505161439.2755fcb6.davem@davemloft.net>
References: <20050504230731.12be1bc3.davem@davemloft.net>
	<20050505153532.30159bd5.davem@davemloft.net>
	<20050505231141.GB16593@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20050505231141.GB16593@krispykreme>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 May 2005 09:11:41 +1000
Anton Blanchard <anton@samba.org> wrote:

> 
> > Is anyone testing this or is everyone too scared? :-)
> > 
> > A lot of people wanted this TSO stuff fixed, so I spent
> > time implementing the fix.  Yet nobody seems interested
> > enough to even say "it works" or "it's busted" :-/
> 
> When I can get my machines booting to userspace Im definitely going to
> try it out :)

Do you need anything besides that early-packet fix from
Herbert?
