From: Edward Ando <edwardando-dbx96nzIXN7OeuqD6ShaSA@public.gmane.org>
Subject: Removing the prism54 module
Date: Sat, 28 Jul 2007 22:40:08 +0200
Message-ID: <20070728224008.782a3be6@ed.anywhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear All,
I am trying to set up software suspend 2 (TuxOnIce now it seems). This
has decided it wants to remove the prism54 module before starting the
hibernate process.

When it tries to do this, (or when I manually do: "ifconfig eth1
down"), I start getting these messages on all terminals, ad infinitum:

kernel: unregister_netdevice: waiting for eth1 to become free. Usage
count = 4

I asked a bit on #prism54 on freenode, and so I upgraded to
linux 2.6.22.1 from kernel.org, always building prism54 as a module,
but the problem continues.

I have tried doing "ifconfig eth1 down" before rmmod, but this does not
help.

If you have any hints or answers as to what I should do, that would be
great. I am not subscribed, so could you answer to this address please.


Thanks in advance,
Yours,

Edward Ando
