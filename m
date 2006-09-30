From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [SCTP]: Enable Nagle algorithm by default.
Date: Fri, 29 Sep 2006 17:08:13 -0700 (PDT)
Message-ID: <20060929.170813.98556311.davem@davemloft.net>
References: <1159560003.29637.45.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17035
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932382AbWI3AIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 20:08:11 -0400
To: sri@us.ibm.com
In-Reply-To: <1159560003.29637.45.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 29 Sep 2006 13:00:03 -0700

> [SCTP]: Enable Nagle algorithm by default.
> 
> This allows more aggressive bundling of chunks when sending small
> messages.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks.
