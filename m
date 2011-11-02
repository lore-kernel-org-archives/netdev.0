From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: stop using on-stack napi struct
Date: Wed, 02 Nov 2011 01:00:47 -0400 (EDT)
Message-ID: <20111102.010047.414830511681971161.davem@davemloft.net>
References: <1320163450.11011.19.camel@lb-tlvb-ariel.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemlof.net, netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab1KBFAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 01:00:50 -0400
In-Reply-To: <1320163450.11011.19.camel@lb-tlvb-ariel.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Tue, 1 Nov 2011 18:04:10 +0200

> Napi structure was allocated on stack to hold temporary value of copied
> fastpath. This can be avoided by using the source fastpath as a
> scratchpad thus saving stack space and code.
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Your patch has been severely corrupted by your email client.

I'm sure your colleagues at Broadcom can help you fix this
so that you can submit this patch properly. :-)
