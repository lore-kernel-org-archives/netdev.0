From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sit: fix some __be16/u16 mismatches
Date: Thu, 05 Feb 2015 00:43:41 -0800 (PST)
Message-ID: <20150205.004341.1829850836694269607.davem@davemloft.net>
References: <1423091524.31870.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753599AbbBEInm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 03:43:42 -0500
In-Reply-To: <1423091524.31870.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Feb 2015 15:12:04 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Fixes following sparse warnings :
...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
