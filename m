From: David Miller <davem@davemloft.net>
Subject: Re: [v1 PATCH 5/14] test_rhashtable: Use rhashtable max_size
 instead of max_shift
Date: Sun, 15 Mar 2015 23:50:07 -0400 (EDT)
Message-ID: <20150315.235007.604573771199422107.davem@davemloft.net>
References: <20150315104306.GA21999@gondor.apana.org.au>
	<E1YX622-0005nK-1e@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbbCPDuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 23:50:11 -0400
In-Reply-To: <E1YX622-0005nK-1e@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 15 Mar 2015 21:44:30 +1100

> This patch converts tets_rhashtable to use rhashtable max_size

Typo: test_rhashtable
