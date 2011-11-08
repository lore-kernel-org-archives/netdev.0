From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: drop packets when source address is multicast
Date: Tue, 08 Nov 2011 12:37:27 -0500 (EST)
Message-ID: <20111108.123727.118782804284893587.davem@davemloft.net>
References: <4EB93FA6.3090709@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divinekumar@gmail.com
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37714 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756143Ab1KHRhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 12:37:47 -0500
In-Reply-To: <4EB93FA6.3090709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 08 Nov 2011 09:41:42 -0500

> RFC 4291 Section 2.7 says Multicast addresses must not be used as source
> addresses in IPv6 packets - drop them on input so we don't process the
> packet further.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> Reported-and-Tested-by: Kumar Sanghvi <divinekumar@gmail.com>

Applied.
