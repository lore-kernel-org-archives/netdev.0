From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] net: ipv6 eliminate parameter "int addrlen" in function fib6_add_1
Date: Tue, 23 Jul 2013 03:52:18 +0200
Message-ID: <20130723015218.GB30719@order.stressinduktion.org>
References: <1374474069-22675-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:33259 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab3GWBwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 21:52:19 -0400
Content-Disposition: inline
In-Reply-To: <1374474069-22675-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 02:21:09PM +0800, Fan Du wrote:
> The "int addrlen" in fib6_add_1 is rebundant, as we can get it from
> parameter "struct in6_addr *addr" once we modified its type.
> And also fix some coding style issues in fib6_add_1
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Nice one,

  Hannes
