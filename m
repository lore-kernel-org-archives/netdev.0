From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] vlan ioctl propagation (rev.2)
Date: Mon, 9 Aug 2004 16:45:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809164527.66c2bf82.davem@redhat.com>
References: <20040806091305.4d405664@dell_ss3.pdx.osdl.net>
	<20040806132145.675fd17d.davem@redhat.com>
	<20040806143928.711d92eb@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040806143928.711d92eb@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Aug 2004 14:39:28 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Here is a redo of the patch to propagate ethtool and mii ioctl's
> on vlan's to the underlying real device.  This time the request
> is copied to a new buffer, to avoid the colon name rewrite issues.

Applied.
