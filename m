From: David Miller <davem@davemloft.net>
Subject: Re: [RFC DUMMY 05/09]: Use dev->stats
Date: Tue, 05 Jun 2007 12:44:04 -0700 (PDT)
Message-ID: <20070605.124404.99456293.davem@davemloft.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<20070605141258.15650.44308.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, ebiederm@xmission.com, tgraf@suug.ch
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54602
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763358AbXFETnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 15:43:50 -0400
In-Reply-To: <20070605141258.15650.44308.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  5 Jun 2007 16:12:59 +0200 (MEST)

> [DUMMY]: Use dev->stats
> 
> Use dev->stats instead of netdev_priv().
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Looks good.
