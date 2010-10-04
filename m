From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next] nf_nat: make find/put static
Date: Mon, 04 Oct 2010 20:54:12 +0200
Message-ID: <4CAA22D4.9040106@trash.net>
References: <20101002141736.0a31bcd7@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64756 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755333Ab0JDSyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 14:54:15 -0400
In-Reply-To: <20101002141736.0a31bcd7@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 02.10.2010 07:17, schrieb Stephen Hemminger:
> The functions nf_nat_proto_find_get and nf_nat_proto_put are
> only used internally in nf_nat_core. This might break some out
> of tree NAT module.

Applied, thanks Stephen.
