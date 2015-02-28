From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: cleanup static functions
Date: Sat, 28 Feb 2015 16:57:12 -0500 (EST)
Message-ID: <20150228.165712.1475174067350715954.davem@davemloft.net>
References: <1425006539.5565.186.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbbB1V5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 16:57:19 -0500
In-Reply-To: <1425006539.5565.186.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Feb 2015 19:08:59 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_fastopen_create_child() is static and should not be exported.
> 
> tcp4_gso_segment() and tcp6_gso_segment() should be static.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
