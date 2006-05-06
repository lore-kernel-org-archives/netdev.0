From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 4/4] [SCTP]: Fix state table entries for chunks
 received in CLOSED state.
Date: Fri, 05 May 2006 17:06:31 -0700 (PDT)
Message-ID: <20060505.170631.106109901.davem@davemloft.net>
References: <1146856490.7861.36.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46285
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750700AbWEFAGo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 20:06:44 -0400
To: sri@us.ibm.com
In-Reply-To: <1146856490.7861.36.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 05 May 2006 12:14:50 -0700

> [SCTP]: Fix state table entries for chunks received in CLOSED state.
> 
> Discard an unexpected chunk in CLOSED state rather can calling BUG().
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks.
