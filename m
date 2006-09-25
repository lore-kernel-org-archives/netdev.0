From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make cubic the default
Date: Sun, 24 Sep 2006 20:13:59 -0700 (PDT)
Message-ID: <20060924.201359.89064092.davem@davemloft.net>
References: <20060919162355.3a22fec1@localhost.localdomain>
	<20060920081704.GA1812@outpost.ds9a.nl>
	<20060920133258.36ff42ce@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15843
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751364AbWIYDOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 23:14:00 -0400
To: shemminger@osdl.org
In-Reply-To: <20060920133258.36ff42ce@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 20 Sep 2006 13:32:58 -0700

> Change default congestion control used from BIC to the newer CUBIC
> which it the successor to BIC but has better properties over long delay links.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Also applied, thanks a lot.
