From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (2/6) ipvs -- get rid of register in declarations
Date: Sat, 20 Sep 2003 01:01:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920010106.1d5c895f.davem@redhat.com>
References: <20030916141739.22ff0101.shemminger@osdl.org>
	<Pine.LNX.4.44.0309180006470.15676-100000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, lvs-users@LinuxVirtualServer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
In-Reply-To: <Pine.LNX.4.44.0309180006470.15676-100000@penguin.linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Sep 2003 00:09:52 +0800 (CST)
Wensong Zhang <wensong@linux-vs.org> wrote:

> If we are gonna to remove register in declarations, it is good to remove 
> all of them, for example in the ip_vs_rr.c, ip_vs_wrr.c, ip_vs_wlc.c,
> ip_vs_nq.c and ip_vs_sed.c.

For now I've applied Stephen's patch, someone can send me
another patch for the rest of them.
