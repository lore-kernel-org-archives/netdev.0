From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: use ipv6_addr_copy() in ip6_route_redirect()
Date: Wed, 07 Oct 2009 13:58:08 -0700 (PDT)
Message-ID: <20091007.135808.186865875.davem@davemloft.net>
References: <4ACCB7ED.7070901@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759819AbZJGU6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 16:58:13 -0400
In-Reply-To: <4ACCB7ED.7070901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 07 Oct 2009 11:46:53 -0400

> Change ip6_route_redirect() to use ipv6_addr_copy().
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied.
