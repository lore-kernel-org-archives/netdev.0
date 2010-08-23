From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 15:16:45 -0700 (PDT)
Message-ID: <20100823.151645.149802880.davem@davemloft.net>
References: <20100823200820.GB5896@nuttenaction>
	<20100823.142114.220045878.davem@davemloft.net>
	<20100823215115.GA2745@nuttenaction>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, ilpo.jarvinen@helsinki.fi,
	therbert@google.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53404
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754326Ab0HWWQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 18:16:27 -0400
In-Reply-To: <20100823215115.GA2745@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Mon, 23 Aug 2010 23:51:15 +0200

> I don't know how many packets the current average HTTP session
> includes, but assuming ~20 packets the saving of one packet is a
> benefit.

Assuming no packet loss.
