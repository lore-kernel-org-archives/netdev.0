From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] set owner on /proc/net/rt6_stats
Date: Sat, 16 Aug 2003 07:48:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030816074809.629c20da.davem@redhat.com>
References: <20030815110107.3ea9b4dc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030815110107.3ea9b4dc.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Aug 2003 11:01:07 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Fix up initialization of IPV6 /proc/net/rt6_stats entries so owner field is set.
> Use proc_net_fops_create helper instead of proc_net_create and fops assignment.

Patch applied, thanks Stephen.
