From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH]: Pass link level header from/to PPP interface
Date: Tue, 12 Feb 2008 22:06:03 -0800 (PST)
Message-ID: <20080212.220603.111665989.davem@davemloft.net>
References: <ygfprv55egs.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: urs@isnogud.escape.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56768
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752380AbYBMGFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 01:05:31 -0500
In-Reply-To: <ygfprv55egs.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Urs Thuermann <urs@isnogud.escape.de>
Date: 10 Feb 2008 10:48:51 +0100

> So what is your opinion about this change?

No general objections from me.

But if libpcap and tcpdump can already identify PPP packets
then, besides "consistency", what does this buy us other
than potential breakage?
