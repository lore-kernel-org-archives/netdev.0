From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: [PATCH] convering bonding driver /proc interface to seq_file
Date: Thu, 21 Aug 2003 20:27:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030822002742.GA99843@calma.pair.com>
References: <20030821165258.45f1ec53.shemminger@osdl.org> <Mutt.LNX.4.44.0308221016320.993-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, Jay Vosburgh <fubar@us.ibm.com>,
   "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
Content-Disposition: inline
In-Reply-To: <Mutt.LNX.4.44.0308221016320.993-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > The name "/proc/net/bond0/info" is kind of unconventional, but now
> > changing that in a almost stable release would be bad.  Better choice
> > would be "/proc/net/bonding/bond0".
> 
> I'm not sure it's too late to do this.

It certainly would match what other drivers do.

Chad
