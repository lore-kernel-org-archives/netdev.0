From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] make netdevice.h more non-kernel friendly
Date: Mon, 15 Mar 2004 13:38:41 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315133841.44b4ccdd.davem@redhat.com>
References: <20040312112442.3ba028a9@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040312112442.3ba028a9@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Mar 2004 11:24:42 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Discovered this trying to build iproute2 with 2.6.4.  The netdevice.h drags
> in a lot of stuff that it doesn't need for the non-kernel interface.
> Just moving the ifdef up a little got rid of the issues.

Ok, fine with me.

Applied.
