From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] icmpv6_filter: fix "_hdr" incorrectly
 being a pointer
Date: Fri, 02 Aug 2013 15:16:23 -0700 (PDT)
Message-ID: <20130802.151623.1481556470533566294.davem@davemloft.net>
References: <cover.1375417279.git.werner@almesberger.net>
	<45f3417354a033cf71cb5e70b5cdf8c9e542e234.1375417279.git.werner@almesberger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: werner@almesberger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306Ab3HBWQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 18:16:25 -0400
In-Reply-To: <45f3417354a033cf71cb5e70b5cdf8c9e542e234.1375417279.git.werner@almesberger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Werner Almesberger <werner@almesberger.net>
Date: Fri, 2 Aug 2013 10:51:19 -0300

> "_hdr" should hold the ICMPv6 header while "hdr" is the pointer to it.
> This worked by accident.
> 
> Signed-off-by: Werner Almesberger <werner@almesberger.net>

Applied.
