From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/8) add probe_old_netdevs hook
Date: Wed, 3 Sep 2003 20:41:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903204150.14273da8.davem@redhat.com>
References: <20030903164908.14705874.shemminger@osdl.org>
	<3F568C88.4030303@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F568C88.4030303@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 03 Sep 2003 20:51:20 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> All the patches except for #3 look ok to me.
> 
> David?

I feel the same, the probe ordering in #3 is unacceptable
and has to be undone.

I'll apply all the other patches except that one.
