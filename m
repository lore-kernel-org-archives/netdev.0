From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH iproute2 v2] GRE over IPv6 tunnel support
Date: Sat, 28 Jul 2012 00:58:40 -0700 (PDT)
Message-ID: <20120728.005840.1291749042220566023.davem@davemloft.net>
References: <20120728115226.66da9d77@comp1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540Ab2G1H6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 03:58:41 -0400
In-Reply-To: <20120728115226.66da9d77@comp1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kozlov <xeb@mail.ru>
Date: Sat, 28 Jul 2012 11:52:26 +0400

> GRE over IPv6 tunnel support.
> 
> Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
> ---
> Changes:
> Implemented 'ip link' family of commands to manage
> ip6gre/ip6gretap tunnels.

Can you please stop sending your patches multiple times?

This is the second time you've done this today.

It makes extra work for us, because we have to keep blowing away the
spurious entries you keep adding to our automated patch queue at:

http://patchwork.ozlabs.org/project/netdev/list/

Thanks.
