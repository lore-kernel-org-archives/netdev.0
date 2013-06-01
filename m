From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: skbuff: use _RET_IP_
Date: Fri, 31 May 2013 17:10:23 -0700 (PDT)
Message-ID: <20130531.171023.192971627043674196.davem@davemloft.net>
References: <1369861743.4188.33.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davidlohr.bueso@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715Ab3FAAKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:10:25 -0400
In-Reply-To: <1369861743.4188.33.camel@buesod1.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davidlohr Bueso <davidlohr.bueso@hp.com>
Date: Wed, 29 May 2013 14:09:03 -0700

> Use the already defined macro to pass the function return address.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>

I've decided that we should just leave this alone for now, because
frankly the choice is arbitrary.
