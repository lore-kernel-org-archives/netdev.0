From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: fix rcu check warning in multicast
 port group
Date: Sun, 04 Aug 2013 18:42:27 -0700 (PDT)
Message-ID: <20130804.184227.1236705052654250661.davem@davemloft.net>
References: <20130804171938.0d515529@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab3HEBm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 21:42:28 -0400
In-Reply-To: <20130804171938.0d515529@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 4 Aug 2013 17:19:38 -0700

> Use of RCU here with out marked pointer and function doesn't match prototype
> with sparse.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
