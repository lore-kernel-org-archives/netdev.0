From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH iproute2] ss: add fastopen support
Date: Fri, 29 Mar 2013 16:56:59 -0400 (EDT)
Message-ID: <20130329.165659.1297013790823482161.davem@davemloft.net>
References: <1364590317.5113.63.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756969Ab3C2U5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 16:57:04 -0400
In-Reply-To: <1364590317.5113.63.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Mar 2013 13:51:57 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> ss -i can output "fastopen" attribute if socket used Fast Open
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Reviewed-by: David S. Miller <davem@davemloft.net>
