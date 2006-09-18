From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] change netfilter tunables to __read_mostly
Date: Mon, 18 Sep 2006 00:05:37 -0700 (PDT)
Message-ID: <20060918.000537.122618085.davem@davemloft.net>
References: <44F85276.1020804@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6532
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965509AbWIRHFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:05:38 -0400
To: brian.haley@hp.com
In-Reply-To: <44F85276.1020804@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 01 Sep 2006 11:32:06 -0400

> Change some netfilter tunables to __read_mostly.  Also fixed some 
> incorrect file reference comments while I was in there.
> 
> (this will be my last __read_mostly patch unless someone points out 
> something else that needs it)
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied, thanks.
