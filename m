From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x.c: encapsulate enable irq calls
Date: Fri, 22 Jun 2012 17:07:12 -0700 (PDT)
Message-ID: <20120622.170712.120946719835620214.davem@davemloft.net>
References: <1340363415-10118-1-git-send-email-mbrugger@iseebcn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org
To: mbrugger@iseebcn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab2FWAHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 20:07:13 -0400
In-Reply-To: <1340363415-10118-1-git-send-email-mbrugger@iseebcn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Brugger <mbrugger@iseebcn.com>
Date: Fri, 22 Jun 2012 13:10:15 +0200

> We encapsulate enbale irq functionality in a function call.
> As on probe the interrupts will be disabled twice, we delete
> one.
> 
> Signed-off-by: Matthias Brugger <mbrugger@iseebcn.com>

Applied to net-next.
