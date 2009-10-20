From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4 v3] net: Fix for dst_negative_advice
Date: Mon, 19 Oct 2009 21:17:07 -0700 (PDT)
Message-ID: <20091019.211707.137231947.davem@davemloft.net>
References: <20091018130816.3960.87384.sendpatchset@localhost.localdomain>
	<20091019131209.1c782c8a@s6510>
	<OF47BDCCCB.33D1775A-ON65257654.00178901-65257654.00192AA2@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dada1@cosmosbay.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51775
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750996AbZJTEQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 00:16:45 -0400
In-Reply-To: <OF47BDCCCB.33D1775A-ON65257654.00178901-65257654.00192AA2@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Mon, 19 Oct 2009 10:04:53 +0530

> Should I resubmit with the changed order?

I took care of this.

I put the patch that actually makes dev.c use sk_tx_queue_mapping
last in the set.

All applied, thanks everyone.
