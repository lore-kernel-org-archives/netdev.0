From: David Miller <davem@davemloft.net>
Subject: Re: [RFC NETLINK 01/09]: Mark netlink policies const
Date: Tue, 05 Jun 2007 12:39:10 -0700 (PDT)
Message-ID: <20070605.123910.116355017.davem@davemloft.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<20070605141252.15650.91283.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, ebiederm@xmission.com, tgraf@suug.ch
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54569
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763648AbXFETi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 15:38:56 -0400
In-Reply-To: <20070605141252.15650.91283.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  5 Jun 2007 16:12:52 +0200 (MEST)

> [NETLINK]: Mark netlink policies const
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

This one looks good enough for 2.6.22, as I consider more
accurate typing a way to prevent and find bugs.

So I'll apply this one now, thanks!
