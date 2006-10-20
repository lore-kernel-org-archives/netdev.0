From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Fri, 20 Oct 2006 00:27:39 -0700 (PDT)
Message-ID: <20061020.002739.26277758.davem@davemloft.net>
References: <20061016.223513.35356292.davem@davemloft.net>
	<200610171458.37636.dada1@cosmosbay.com>
	<200610191127.50831.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40682
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S2992551AbWJTH1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 03:27:54 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200610191127.50831.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 19 Oct 2006 11:27:50 +0200

> Here is the second try for this patch. Many thanks for your feedback.
> 
> [PATCH] [NET] Size listen hash tables using backlog hint

This version looks very good.  It's not a major bug fix (obviously) so
we'll have to defer it to 2.6.20, so please resubmit once I open up
the net-2.6.20 tree.

Thanks a lot!

