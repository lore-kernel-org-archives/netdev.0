From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][SCTP]: Fix the RX queue size shown in
 /proc/net/sctp/assocs output.
Date: Mon, 09 Oct 2006 21:34:49 -0700 (PDT)
Message-ID: <20061009.213449.89037922.davem@davemloft.net>
References: <1160440992.27455.6.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28570
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964965AbWJJEeu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 00:34:50 -0400
To: sri@us.ibm.com
In-Reply-To: <1160440992.27455.6.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 09 Oct 2006 17:43:12 -0700

> [SCTP]: Fix the RX queue size shown in /proc/net/sctp/assocs output.
> 
> Show the true receive buffer usage.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Also applied, thanks a lot.
