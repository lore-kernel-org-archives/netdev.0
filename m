From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tun -- name fix
Date: Mon, 15 Mar 2004 12:40:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315124050.3e7be662.davem@redhat.com>
References: <20040313164325.070524df.akpm@osdl.org>
	<20040315102215.65c26745@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, kraxel@bytesex.org, rutger@mail.com, netdev@oss.sgi.com,
        maxk@qualcomm.com, vtun@office.satix.net.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040315102215.65c26745@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Mar 2004 10:22:15 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> This fixes both the devfs name and the /sys name issues.
> It ends up as /dev/net/tun and /sys/class/misc/tun looks correct.

Applied, thanks Stephen.
