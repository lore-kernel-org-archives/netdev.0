From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Change some sysctl variables to __read_mostly
Date: Tue, 15 Aug 2006 01:38:15 -0700 (PDT)
Message-ID: <20060815.013815.125563439.davem@davemloft.net>
References: <44D9FA8E.2030602@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55688
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965286AbWHOIiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 04:38:14 -0400
To: brian.haley@hp.com
In-Reply-To: <44D9FA8E.2030602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 09 Aug 2006 11:09:02 -0400

> Change net/core, ipv4 and ipv6 sysctl variables to __read_mostly.
> 
> Couldn't actually measure any performance increase while testing (.3% I 
> consider noise), but seems like the right thing to do.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied, thanks a lot Brian.
