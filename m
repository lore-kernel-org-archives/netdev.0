From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Avoid changing vlan flags
Date: Tue, 28 Dec 2010 13:51:53 -0800 (PST)
Message-ID: <20101228.135153.59670582.davem@davemloft.net>
References: <AANLkTimODzrAWS+05+FChtme_3um_9Ky7cwa3gWHFaXp@mail.gmail.com>
	<1292871757-24918-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, jesse@nicira.com
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58476
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751136Ab0L1VvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Dec 2010 16:51:22 -0500
In-Reply-To: <1292871757-24918-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Mon, 20 Dec 2010 17:02:37 -0200

> This patch avoids disabling the vlan flags using ethtool.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied.

Although in the long term, having each and every driver handle this
seems rediculious.
