From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: fix missing free per cpu on qstats
Date: Tue, 05 Jan 2016 14:14:14 -0500 (EST)
Message-ID: <20160105.141414.1740662502267457665.davem@davemloft.net>
References: <20160105171136.9063.98710.stgit@john-Precision-Tower-5810>
	<1452015851.8255.108.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org,
	daniel@iogearbox.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbcAETOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 14:14:16 -0500
In-Reply-To: <1452015851.8255.108.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Jan 2016 09:44:11 -0800

> David, please add the following tag to ease backports to stable kernels:
> 
> Fixes: 22e0f8b9322cb ("net: sched: make bstats per cpu and estimator RCU safe")

Ok, will do, thanks!
