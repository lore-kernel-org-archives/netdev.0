From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] convert lp486e driver to dynamic allocation
Date: Mon, 4 Aug 2003 16:59:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030804165904.0e9f60ab.davem@redhat.com>
References: <20030804162147.591c55f6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030804162147.591c55f6.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Aug 2003 16:21:47 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Convert this driver from static net_device to using alloc_etherdev.

Applied, thanks.
