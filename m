From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2010-02-10
Date: Wed, 10 Feb 2010 11:36:58 -0800 (PST)
Message-ID: <20100210.113658.137273026.davem@davemloft.net>
References: <20100210185816.GB3286@tuxdriver.com>
	<20100210.110756.201335073.davem@davemloft.net>
	<1265829337.19075.0.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751736Ab0BJTgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 14:36:44 -0500
In-Reply-To: <1265829337.19075.0.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 10 Feb 2010 20:15:37 +0100

> It was intentional -- that sdev doesn't even have an irq member, but
> nobody ever noticed because of the wrong ifdef.

Ok, then this needs to be explained in the commit message.

