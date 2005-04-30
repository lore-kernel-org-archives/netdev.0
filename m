From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] [RTNETLINK] Cleanup rtnetlink_link tables
Date: Sat, 30 Apr 2005 22:23:52 +0200
Message-ID: <20050430202352.GG577@postel.suug.ch>
References: <20050430195243.GE577@postel.suug.ch> <1114892357.8929.151.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114892357.8929.151.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1114892357.8929.151.camel@localhost.localdomain> 2005-04-30 16:19
> On Sat, 2005-30-04 at 21:52 +0200, Thomas Graf wrote:
> > Converts remaining rtnetlink_link tables to use c99 designated
> > initializers to make greping a little bit easier.
> > 
> 
> Looks nice. You may wanna make net/xfrm/xfrm_user.c equally readble as
> well.

Right, missed that one because it doesn't use rtnetlink_link.
