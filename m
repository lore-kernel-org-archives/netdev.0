From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: support ipv6 nonlocal bind
Date: Mon, 25 Jul 2016 10:46:38 -0700 (PDT)
Message-ID: <20160725.104638.747513236812194365.davem@davemloft.net>
References: <b3a6fd04f36bcfc5557d70ba79cddfc9c5d33b3c.1469180331.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbcGYRqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 13:46:39 -0400
In-Reply-To: <b3a6fd04f36bcfc5557d70ba79cddfc9c5d33b3c.1469180331.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 22 Jul 2016 17:38:51 +0800

> This patch makes sctp support ipv6 nonlocal bind by adding
> sp->inet.freebind and net->ipv6.sysctl.ip_nonlocal_bind
> check in sctp_v6_available as what sctp did to support
> ipv4 nonlocal bind (commit cdac4e077489).
> 
> Reported-by: Shijoe George <spanjikk@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
