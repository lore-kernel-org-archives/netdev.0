From: "David S. Miller" <davem@redhat.com>
Subject: Re: The recent free_netdev() conversion...
Date: Mon, 1 Sep 2003 08:58:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901085814.5a333518.davem@redhat.com>
References: <3F535EBD.6090401@pobox.com>
	<20030901075345.4c35e3e6.davem@redhat.com>
	<3F536CB7.6060404@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F536CB7.6060404@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 01 Sep 2003 11:58:47 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> True, but for long term, it's best to use free_netdev().  Besides 
> naturally pairing with alloc_foodev(), if we ever decide to have 
> alloc_netdev() perform more than one allocation, free_netdev() will 
> already be in place to handle the multiple de-allocations.

Okie dokie, I'll take patches that fix any of these
cases.
