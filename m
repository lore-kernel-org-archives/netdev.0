From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
 take 2
Date: Fri, 31 Aug 2007 15:24:51 -0700 (PDT)
Message-ID: <20070831.152451.74561105.davem@davemloft.net>
References: <46D88146.9090401@hp.com>
	<20070831.143855.88699905.davem@davemloft.net>
	<46D89444.3080508@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60012
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751955AbXHaWYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 18:24:53 -0400
In-Reply-To: <46D89444.3080508@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 31 Aug 2007 15:20:52 -0700

> I'm going to go ahead and take a look at input vs output units and 
> differences between those with rto_min vs rtt.

You better because that's one of the last non-trivial emails you'll
get for me over the next few days while I'm travelling to kernel
summit :-)

