From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove ipv6_addr_copy()
Date: Tue, 22 Nov 2011 16:53:24 -0500 (EST)
Message-ID: <20111122.165324.1422154522209575302.davem@davemloft.net>
References: <20111121133903.GA18453@p183.telecom.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab1KVVx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 16:53:28 -0500
In-Reply-To: <20111121133903.GA18453@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 21 Nov 2011 16:39:03 +0300

> C assignment can handle struct in6_addr copying.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Fair enough, applied.
