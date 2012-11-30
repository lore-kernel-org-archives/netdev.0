From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: unify logic evaluating inet6_dev's accept_ra
 property
Date: Fri, 30 Nov 2012 15:02:16 -0500 (EST)
Message-ID: <20121130.150216.558209297528016175.davem@davemloft.net>
References: <1354181179-16294-1-git-send-email-shmulik.ladkani@gmail.com>
	<20121130.120943.1397811156693287841.davem@davemloft.net>
	<20121130215113.7a81bc16.shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, tgraf@suug.ch,
	tore@fud.no
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933648Ab2K3UCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 15:02:17 -0500
In-Reply-To: <20121130215113.7a81bc16.shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Fri, 30 Nov 2012 21:51:13 +0200

> BTW the "Not like this" style has many occurrences in net/ipv6.
> One of which was the comment relocated by my patch :-)

Patches to fix this are more than welcome :-)
