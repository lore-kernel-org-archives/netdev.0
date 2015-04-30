From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: set SOCK_NOSPACE under memory presure
Date: Thu, 30 Apr 2015 11:44:38 -0400 (EDT)
Message-ID: <20150430.114438.1344047101033865261.davem@davemloft.net>
References: <20150421.173300.553980773035401270.davem@davemloft.net>
	<5537AF76.1020108@akamai.com>
	<55423D69.7000907@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57239 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbbD3Pom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 11:44:42 -0400
In-Reply-To: <55423D69.7000907@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Thu, 30 Apr 2015 10:34:17 -0400

> Just curious if anybody had any further reaction on this issue.
> I think making the epoll edge trigger case, as least match what
> we are seeing for poll()/select()/epoll() level trigger seems
> reasonable here.

It's in my inbox and looking into this is on my TODO list.

I simply lack the time right now and you will need to be
patient.
