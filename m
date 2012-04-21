From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_packet: packet_getsockopt() cleanup
Date: Sat, 21 Apr 2012 16:31:59 -0400 (EDT)
Message-ID: <20120421.163159.1025498440990500029.davem@davemloft.net>
References: <1334908571.2395.228.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604Ab2DUUcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 16:32:01 -0400
In-Reply-To: <1334908571.2395.228.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Apr 2012 09:56:11 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Factorize code, since most fetched values are int type.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
