From: jamal <hadi@cyberus.ca>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: 22 Apr 2004 09:22:16 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1082640135.1059.93.camel@jzny.localdomain>
References: <XFMail.20040422102359.pochini@shiny.it>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, cfriesen@nortelnetworks.com,
	=?ISO-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264023AbUDVNWx@vger.kernel.org>
To: Giuliano Pochini <pochini@shiny.it>
In-Reply-To: <XFMail.20040422102359.pochini@shiny.it>
List-Id: netdev.vger.kernel.org

On Thu, 2004-04-22 at 04:23, Giuliano Pochini wrote:

> Yes, but it is possible, expecially for long sessions. 

In other words, 80% or more of internet traffic would not be affected
still using http1.0 would not be affected.
And for something like a huge download to just regular joe, this is more
of a nuisance assuming some kiddie has access between you and the
server.
OTOH, long lived BGP sessions are affected assuming you are going across
hostile path to your peer.

So whats all this ado about nothing? Local media made it appear we are
all about to die.

Is anyone working on some fix?

cheers,
jamal
