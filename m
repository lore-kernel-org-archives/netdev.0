From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] deprecate dev_get
Date: Sat, 20 Sep 2003 01:10:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030920011010.3337d12d.davem@redhat.com>
References: <20030915171230.68c08e26.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030915171230.68c08e26.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Sep 2003 17:12:30 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The interface dev_get has past it's usefulness.  I sent out patches
> that remove the two other uses left of it in the 2.6 tree.
> 
> This marks it as deprecated because there still may be out of tree
> drivers that use it.

I've applied this, and I'll apply your fix next.

Even though Jeff hasn't pushed your other bits yet, the warnings will
just go away once he gets to that.
