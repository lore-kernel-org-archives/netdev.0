From: Jeff Garzik <jeff@garzik.org>
Subject: Re: net-next-2.6...
Date: Mon, 27 Oct 2008 14:53:56 -0400
Message-ID: <49060E44.5070604@garzik.org>
References: <20081027.113503.149366323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53138 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360AbYJ0SyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 14:54:01 -0400
In-Reply-To: <20081027.113503.149366323.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Stephen Rothwell said earlier today that it's OK to "let it rip"
> and allow new changes to start flowing into the linux-next tree.
> 
> So I'll likely get the net-next-2.6 going today.
> 
> First I'll cut the tree with a fresh clone of Linus's current stuff,
> then add in all the things which are in the queue already (Neil's
> routing cache hacks, Thomas Graf's cgroup work, the print_mac() %pX
> bits, etc.)
> 
> As always you can get a good idea of what will be looked at and considered
> by taking a look at the patchwork queue for netdev:
> 
> 	http://patchwork.ozlabs.org/
> 
> I'll make another posting when the new tree is up and operational.

Likewise, as soon as net-next-2.6 opens, I'll be taking patches for 
drivers/net/*

	Jeff


