From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net/tokenring: use module_pci_driver
Date: Sat, 14 Apr 2012 15:20:17 -0400 (EDT)
Message-ID: <20120414.152017.365753575994056358.davem@davemloft.net>
References: <1334378323.2862.1.camel@phoenix>
	<1334378417.2862.3.camel@phoenix>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhowells@redhat.com
To: axel.lin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853Ab2DNTUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 15:20:20 -0400
In-Reply-To: <1334378417.2862.3.camel@phoenix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Axel Lin <axel.lin@gmail.com>
Date: Sat, 14 Apr 2012 12:40:17 +0800

> This patch converts the drivers in drivers/net/tokenring/* to use
> module_pci_driver() macro which makes the code smaller and a bit simpler.
> 
> Signed-off-by: Axel Lin <axel.lin@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: David Howells <dhowells@redhat.com>

Applied.
