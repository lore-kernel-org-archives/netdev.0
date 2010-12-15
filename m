From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] Documentation/networking/l2tp.txt: update
 documentation.
Date: Wed, 15 Dec 2010 10:52:07 -0800
Message-ID: <20101215105207.29b1a837@nehalam>
References: <AANLkTimhKtb+p6-4bG7QXBmUZ5YX=m5u1ZkxEb94e1K1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jchapman@katalix.com
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50434 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364Ab0LOSwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 13:52:14 -0500
In-Reply-To: <AANLkTimhKtb+p6-4bG7QXBmUZ5YX=m5u1ZkxEb94e1K1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Dec 2010 20:40:38 +0200
David Shwatrz <dshwatrz@gmail.com> wrote:

> Hi,
> 
> This patch updates Documentation/networking/l2tp.txt.
> Stephen Hemminger (maintainer of iproute2) rejected patches for
> iproute2 which enable
> "ip l2tp" commands. There is a utility called l2tpv3tun which
> has commands to doing the same (managing static L2TPv3 tunnel).
> see:
> http://www.spinics.net/lists/netdev/msg142037.html
> 
> 
> Regards,
> David Shwartz
> 
> Signed-off-by: David Shwartz <dshwatrz@gmail.com>

I wish you would stop whining about it and just reimplement
without using libnl as requested.

-- 
