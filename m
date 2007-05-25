From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND][PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Thu, 24 May 2007 19:03:21 -0700 (PDT)
Message-ID: <20070524.190321.104645132.davem@davemloft.net>
References: <4655B9C2.4050200@trash.net>
	<1180057935.4069.5.camel@localhost>
	<1180058280.4069.9.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com, tgraf@suug.ch,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	sri@us.ibm.com, auke-jan.h.kok@intel.com, krkumar2@in.ibm.com,
	xma@us.ibm.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39582
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751088AbXEYCDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 22:03:17 -0400
In-Reply-To: <1180058280.4069.9.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 24 May 2007 21:58:00 -0400

> Dave please apply this patch; against latest net-2.6 

Jamal, as much as I love your patch, it's a cleanup and doesn't
fix any bugs and we're outside of the merge window for 2.6.22

I'll queue this up for sure when I open up the 2.6.23 tree.

Thanks.
