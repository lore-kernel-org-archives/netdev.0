From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Thu, 20 Sep 2012 15:30:18 -0400 (EDT)
Message-ID: <20120920.153018.1693489820883898343.davem@davemloft.net>
References: <1348088634.31352.26.camel@edumazet-glaptop>
	<CAEkNxbEJjAu3+3yDGPGSzzee-LY_797RdNbBgcC6=-aDHfEAJQ@mail.gmail.com>
	<505AFDE9.4080602@earthlink.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brutus@google.com, eric.dumazet@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093Ab2ITTa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 15:30:26 -0400
In-Reply-To: <505AFDE9.4080602@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Clark <sclark46@earthlink.net>
Date: Thu, 20 Sep 2012 07:28:41 -0400

> Does this mean traffic on the loopback interface will not traverse
> netfilter?

Please, we've had this discussion before, let's not have it again.
Read the archives for the postings of the previous versions of
this patch.
