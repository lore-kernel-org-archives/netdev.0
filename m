From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: Fixing EEH handlers
Date: Fri, 11 Dec 2009 15:16:50 -0800 (PST)
Message-ID: <20091211.151650.110899170.davem@davemloft.net>
References: <1260471817-7184-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40624
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762659AbZLKXQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 18:16:44 -0500
In-Reply-To: <1260471817-7184-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Thu, 10 Dec 2009 13:03:37 -0600

> After commit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff, the EEH
> is not working proplery on cxgb3.
> 
> This patch fixes it, always saving the PCI state after a recovery,
> in order to allow further reoveries.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied.
