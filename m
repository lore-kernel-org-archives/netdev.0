From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND: PATCH] l2tp: Fix UDP socket reference count bugs in
 the pppol2tp driver
Date: Tue, 16 Mar 2010 14:29:13 -0700 (PDT)
Message-ID: <20100316.142913.145795333.davem@davemloft.net>
References: <20100316162920.20459.11487.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41935
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758113Ab0CPV2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:28:51 -0400
In-Reply-To: <20100316162920.20459.11487.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Tue, 16 Mar 2010 16:29:20 +0000

> This patch fixes UDP socket refcnt bugs in the pppol2tp driver.

Sorry for not getting to this sooner, thanks for resubmitting.

Applied, thanks!
