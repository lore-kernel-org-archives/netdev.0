From: David Miller <davem@davemloft.net>
Subject: Re: arp_hash
Date: Sun, 22 Mar 2015 12:57:19 -0400 (EDT)
Message-ID: <20150322.125719.1169454679383971303.davem@davemloft.net>
References: <20150322114204.GA5010@gondor.apana.org.au>
	<1427028981.25985.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	roland@purestorage.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47410 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbbCVQ5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 12:57:21 -0400
In-Reply-To: <1427028981.25985.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 22 Mar 2015 05:56:21 -0700

> Anyway, trying to avoid ARP 'attacks' is a lost battle.
> 
> Adding jhash() or whatever crypto will not fundamentally avoid the
> issue there.

+1
