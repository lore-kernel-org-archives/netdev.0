From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 11/11]: qdisc: avoid dequeue while throttled
Date: Fri, 23 Mar 2007 11:26:37 -0700 (PDT)
Message-ID: <20070323.112637.63127971.davem@davemloft.net>
References: <20070323133528.10264.68156.sendpatchset@localhost.localdomain>
	<4603E6AE.6000606@trash.net>
	<4603EAC4.7000509@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57505
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753290AbXCWS0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 14:26:38 -0400
In-Reply-To: <4603EAC4.7000509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 23 Mar 2007 15:57:08 +0100

> I found another case that doesn't work properly, so let me retract
> this patch until I've properly thought this through.

Ok, I'll apply the rest.
