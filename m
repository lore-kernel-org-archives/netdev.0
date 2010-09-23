From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] dont create cached routes from ARP requests
Date: Thu, 23 Sep 2010 12:04:02 -0700 (PDT)
Message-ID: <20100923.120402.220062346.davem@davemloft.net>
References: <20100922162209.GA10281@babylon>
	<20100922.203442.233700254.davem@davemloft.net>
	<20100923144708.GA8037@babylon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: uweber@astaro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53944
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752066Ab0IWTDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 15:03:43 -0400
In-Reply-To: <20100923144708.GA8037@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <uweber@astaro.com>
Date: Thu, 23 Sep 2010 16:47:08 +0200

> Forcing the call of rt_garbage_collect didn't help either,
> there are no routes freed afterwards...

Then you need to find out why :-)
