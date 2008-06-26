From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] TCP: de-bloat a bit with factoring
 NET_INC_STATS_BH out
Date: Thu, 26 Jun 2008 02:19:23 -0700 (PDT)
Message-ID: <20080626.021923.164492770.davem@davemloft.net>
References: <485931B5.2020509@openvz.org>
	<48634AC5.20203@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60202
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752348AbYFZJTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 05:19:23 -0400
In-Reply-To: <48634AC5.20203@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 26 Jun 2008 11:52:37 +0400

> The thing is that I'm now almost finished with the MIB netnsization
> patch-set to send for discussion (and, frankly speaking, hopefully
> for the inclusion in 2.6.27) and this work (slightly) depends on this
> patch. And, since I mention, the MIBs - do I have any chance to
> attract your attention to that set? :)

It's sitting in my inbox to read over.  I'll try to look at it
soon :)
