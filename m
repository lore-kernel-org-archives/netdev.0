From: Giuliano Pochini <pochini@denise.shiny.it>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Thu, 22 Apr 2004 15:46:05 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404221532480.670@denise.shiny.it>
References: <XFMail.20040422102359.pochini@shiny.it> <1082640135.1059.93.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, cfriesen@nortelnetworks.com,
        =?ISO-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1082640135.1059.93.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Thu, 22 Apr 2004, jamal wrote:

> On Thu, 2004-04-22 at 04:23, Giuliano Pochini wrote:
>
> > Yes, but it is possible, expecially for long sessions.
>
> In other words, 80% or more of internet traffic would not be affected
> still using http1.0 would not be affected.
> And for something like a huge download to just regular joe, this is more
> of a nuisance assuming some kiddie has access between you and the
> server.

No, TCP/IP is 100% vulnerable to the man-in-the-middle attach. There is no
cure for that. Some devices or softwares called "firewall" are designed to
cut or to modify connections. :)
This vulnerability is about external attacks.


--
Giuliano.
