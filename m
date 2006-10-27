From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: don't allow unfair congestion control to be built
 without warning
Date: Fri, 27 Oct 2006 15:24:44 -0700 (PDT)
Message-ID: <20061027.152444.48528262.davem@davemloft.net>
References: <20061027145913.04dc0e5f@dxpl.pdx.osdl.net>
	<20061027.151238.59655130.davem@davemloft.net>
	<20061027152149.42bcb539@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51084
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750808AbWJ0WZB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 18:25:01 -0400
To: shemminger@osdl.org
In-Reply-To: <20061027152149.42bcb539@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 27 Oct 2006 15:21:49 -0700

> The restricted flag patch which you have ignored, would be a way to
> allow them to be configured but tag the "bad apples" for only
> root usage.

I haven't ignored it, it's in my backlog below more important
things like Appletalk OOPS'ers.
