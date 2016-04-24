From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: zillions of lockdep whinges in
 include/net/sock.h:1408
Date: Sun, 24 Apr 2016 14:54:21 -0400 (EDT)
Message-ID: <20160424.145421.128023840849290353.davem@davemloft.net>
References: <5718DA71.7050902@stressinduktion.org>
	<20160424.143833.2292980084570149367.davem@davemloft.net>
	<571D14F8.6070306@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, Valdis.Kletnieks@vt.edu,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbcDXSyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 14:54:25 -0400
In-Reply-To: <571D14F8.6070306@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 24 Apr 2016 20:48:24 +0200

> Eric's patch is worth to apply anyway, but I am not sure if it solves
> the (fundamental) problem. I couldn't reproduce it with the exact next-
> tag provided in the initial mail. All other reports also only happend
> with linux-next and not net-next.

Ok, Eric please submit it formally.

Thanks!
