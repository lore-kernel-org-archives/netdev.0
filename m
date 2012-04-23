From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/28] MISDN patchset for net-next
Date: Mon, 23 Apr 2012 15:19:53 -0400 (EDT)
Message-ID: <20120423.151953.1258613141357490104.davem@davemloft.net>
References: <20120423170549.33CDA9FB80@pingi6.linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852Ab2DWTUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 15:20:01 -0400
In-Reply-To: <20120423170549.33CDA9FB80@pingi6.linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <isdn@linux-pingi.de>
Date: Mon, 23 Apr 2012 18:03:51 +0200

> please include thes patches into netnext.

Please submit smaller, reasonable, amounts of patches at one time.
Say 10 or so.

Coming out of the blue with a 28 entry patch bomb is not acceptable.

Also, please do not let whatever you're using to submit these patches
take the email date from the commit timestamp in your local tree.

This makes no sense when your submitting patches for someone to apply,
and utterly screws up the order in which the patches show up in
patchwork:

http://patchwork.ozlabs.org/project/netdev/list/
