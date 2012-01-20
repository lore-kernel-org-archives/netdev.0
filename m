From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute: Dump unix sockets via netlink
Date: Fri, 20 Jan 2012 12:51:48 -0800
Message-ID: <20120120125148.536d12fe@nehalam.linuxnetplumber.net>
References: <4EE9EB2A.4040909@parallels.com>
	<4EE9F5EF.8000101@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34154 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753673Ab2ATUvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jan 2012 15:51:51 -0500
In-Reply-To: <4EE9F5EF.8000101@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Dec 2011 17:28:15 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> Get the same info as from /proc file plus the peer inode.
> 
> Applies on top of new sock diag patch and udp diag patch.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> ---

Applied, but was missing sock_diag.h in include's.

Also, please update manual pages.
