From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses as source
 addresses in ICMPv6 error messages
Date: Tue, 21 Jan 2014 16:53:45 -0800 (PST)
Message-ID: <20140121.165345.610272719684281351.davem@davemloft.net>
References: <1390147236-3660-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com,
	billfink@mindspring.com, hannes@stressinduktion.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: fx.lebail@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38715 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753744AbaAVAxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 19:53:46 -0500
In-Reply-To: <1390147236-3660-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Date: Sun, 19 Jan 2014 17:00:36 +0100

> - Uses ipv6_anycast_destination() in icmp6_send().
> 
> Suggested-by: Bill Fink <billfink@mindspring.com>
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>

Applied.
