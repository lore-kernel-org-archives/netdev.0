From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (2/4) convert irlan to use alloc_netdev
Date: Tue, 19 Aug 2003 21:14:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819211452.3e4c8bc0.davem@redhat.com>
References: <20030818114930.4ca873cf.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030818114930.4ca873cf.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 11:49:30 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This patch to 2.6.0-test3 converts irlan to use alloc_netdev.
> 
> Setup auto free via destructor.

Applied, thanks.
