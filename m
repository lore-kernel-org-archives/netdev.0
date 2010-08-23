From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 14:21:14 -0700 (PDT)
Message-ID: <20100823.142114.220045878.davem@davemloft.net>
References: <1282590037-18566-1-git-send-email-hagen@jauu.net>
	<20100823121449.29419771@nehalam>
	<20100823200820.GB5896@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, ilpo.jarvinen@helsinki.fi,
	therbert@google.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751948Ab0HWVU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 17:20:57 -0400
In-Reply-To: <20100823200820.GB5896@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Mon, 23 Aug 2010 22:08:20 +0200

> At least google inc is too busy to disable tcp quick ack's. And I
> think they will save a lot of packets! Who make a bet? ;)

I think assuming that turning off quick ACKs will be a net
positive for google's traffic is a bit presumptuous, don't
you?
