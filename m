From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] s390 network patches
Date: Mon, 14 Dec 2015 16:17:09 -0500 (EST)
Message-ID: <20151214.161709.47793912452228938.davem@davemloft.net>
References: <1449833277-69012-1-git-send-email-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ubraunu@linux.vnet.ibm.com
To: ubraun@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540AbbLNVRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 16:17:12 -0500
In-Reply-To: <1449833277-69012-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Date: Fri, 11 Dec 2015 12:27:49 +0100

> here are some s390 related patches for net-next. Most important is
> the skb_linearize af_iucv patch from Eugene solving traffic problems
> in certain scenarios. The remaining patches are minor improvements.

Series applied to net-next, thanks.
