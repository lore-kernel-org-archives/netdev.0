From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bond: Check length of IFLA_BOND_ARP_IP_TARGET
 attributes
Date: Sat, 29 Nov 2014 20:49:31 -0800 (PST)
Message-ID: <20141129.204931.742410484059672036.davem@davemloft.net>
References: <a7c193909c30dbc19b4f279a3f7ba757107641d3.1417044113.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@cumulusnetworks.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54796 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbaK3EpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 23:45:20 -0500
In-Reply-To: <a7c193909c30dbc19b4f279a3f7ba757107641d3.1417044113.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 27 Nov 2014 00:22:33 +0100

> Fixes: 7f28fa10 ("bonding: add arp_ip_target netlink support")
> Reported-by: John Fastabend <john.fastabend@gmail.com>
> Cc: Scott Feldman <sfeldma@cumulusnetworks.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, and queued up for -stable, thanks.
