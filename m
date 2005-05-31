From: Thomas Graf <tgraf@suug.ch>
Subject: Re: PATCH: rtnetlink explicit flags setting
Date: Wed, 1 Jun 2005 00:26:46 +0200
Message-ID: <20050531222646.GK15391@postel.suug.ch>
References: <1117197157.6688.24.camel@localhost.localdomain> <20050531.144338.112623594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050531.144338.112623594.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050531.144338.112623594.davem@davemloft.net> 2005-05-31 14:43
> From: jamal <hadi@cyberus.ca>
> Date: Fri, 27 May 2005 08:32:37 -0400
> 
> > This patch rectifies some rtnetlink message builders that derive the
> > flags from the pid. It is now explicit like the other cases
> > which get it right.
> > 
> > Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> Please use explicit "unsigned int flags" instead of "unsigned flags".

I converted this already in the two patches later in the thread.
