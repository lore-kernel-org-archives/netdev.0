From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 4/4 net-next] net/l2tp: add support for L2TP over
 IPv6 UDP
Date: Sat, 28 Apr 2012 22:31:51 -0400 (EDT)
Message-ID: <20120428.223151.2193090309460103807.davem@davemloft.net>
References: <20120427182418.GH17021@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902Ab2D2Cb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 22:31:57 -0400
In-Reply-To: <20120427182418.GH17021@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Fri, 27 Apr 2012 14:24:18 -0400

> Now that encap_rcv() works on IPv6 UDP sockets, wire L2TP up to IPv6.
> Support has been tested with and without hardware offloading.  This
> version fixes the L2TP over localhost issue with incorrect checksums
> being reported.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Applied.
