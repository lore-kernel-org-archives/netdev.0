From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] convering bonding driver /proc interface to seq_file
Date: Fri, 22 Aug 2003 10:17:07 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0308221016320.993-100000@excalibur.intercode.com.au>
References: <20030821165258.45f1ec53.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chad Tindel <ctindel@users.sourceforge.net>,
   Jay Vosburgh <fubar@us.ibm.com>, "David S. Miller" <davem@redhat.com>,
   Jeff Garzik <jgarzik@pobox.com>, <bonding-devel@lists.sourceforge.net>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030821165258.45f1ec53.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Aug 2003, Stephen Hemminger wrote:

> The name "/proc/net/bond0/info" is kind of unconventional, but now
> changing that in a almost stable release would be bad.  Better choice
> would be "/proc/net/bonding/bond0".

I'm not sure it's too late to do this.


- James
-- 
James Morris
<jmorris@intercode.com.au>
