From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/11) Irda dongle module owner support
Date: Fri, 3 Oct 2003 06:55:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003065552.6b734105.davem@redhat.com>
References: <20031002152026.4bfd2c67.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031002152026.4bfd2c67.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jean noted some problems he has with these changes, in particular
the hashbin locking bits.

So I'm going to wait until that stuff is resolved since all the other
IRDA patches in this series depend upon this first dongle module owner
infrastructure one.

Or did I misinterpret what happened?
