From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/9][NETNS][IPV6] make bindv6only sysctl per namespace
Date: Wed, 09 Jan 2008 00:25:33 -0800 (PST)
Message-ID: <20080109.002533.265593679.davem@davemloft.net>
References: <20080104111431.444295890@localhost.localdomain>
	<47825402.8030504@bull.net>
	<47825513.50100@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org,
	dada1@cosmosbay.com
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43808
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750884AbYAIIZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 03:25:34 -0500
In-Reply-To: <47825513.50100@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Mon, 07 Jan 2008 17:36:35 +0100

> Thanks Benjamin to catch this.
> 
> I think I have to apologize to Eric, I thought I tested with this option 
> off but it wasn't and Eric was right. I will wait a little for feedbacks 
> and send a V3.

I would have preferred if you just reposted a fixed version of patch 5
instead of waiting for the feedback that realistically isn't going to
come at all after this much time has passed.

I was about to apply this series, then looked through my mailbox for
reported regressions and hit this.

That makes me not start applying your patch series.  I want the whole
thing with known bug fixes available by the time I get around to
reviewing it.

Thanks.
