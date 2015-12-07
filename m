From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/2] vxlan: IPv6 fill_metadata_dst support
Date: Mon, 07 Dec 2015 16:33:20 -0500 (EST)
Message-ID: <20151207.163320.1675757743454319285.davem@davemloft.net>
References: <cover.1449489733.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, pshelar@nicira.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50901 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755679AbbLGVdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 16:33:22 -0500
In-Reply-To: <cover.1449489733.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Mon,  7 Dec 2015 13:04:29 +0100

> This adds IPv6 support to ndo_fill_metadata_dst in vxlan. The IPv4 part
> needs some restructuring to avoid duplicate code, this will be sent as
> a separate patch targeting net-next.

Series applied.
