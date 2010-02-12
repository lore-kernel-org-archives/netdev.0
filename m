From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: fib: fix crash when changing large fib while dumping it
Date: Fri, 12 Feb 2010 12:07:11 -0800 (PST)
Message-ID: <20100212.120711.111422105.davem@davemloft.net>
References: <4B702B67.4000900@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48014
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755971Ab0BLUG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:06:57 -0500
In-Reply-To: <4B702B67.4000900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 08 Feb 2010 16:19:03 +0100

> Please review carefully, I'm not too familiar with this code.

It looks OK to me, I've applied this to net-next-2.6.  We can backport
or submit to -stable if needed after it cooks for a while in
net-next-2.6.
