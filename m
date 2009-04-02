From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] sky2: add GRO support
Date: Thu, 02 Apr 2009 01:08:16 -0700 (PDT)
Message-ID: <20090402.010816.201810059.davem@davemloft.net>
References: <20090401142020.395f51bb@nehalam>
	<20090401143946.64449a05@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33798
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757770AbZDBII1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:08:27 -0400
In-Reply-To: <20090401143946.64449a05@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 1 Apr 2009 14:39:46 -0700

> Add support for generic receive offload. Also cleanup counters so
> that only updated once per interrupt.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ----
> Note: this is experimental at this point (so please hold for 2.6.31)

Ok, please just resubmit this when -rc1 is released.
