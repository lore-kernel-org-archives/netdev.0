From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 0/8] vxlan: bug fixes
Date: Wed, 10 Oct 2012 22:42:20 -0400 (EDT)
Message-ID: <20121010.224220.1261492043652933665.davem@davemloft.net>
References: <20121010063545.453368147@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933061Ab2JKCmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 22:42:21 -0400
In-Reply-To: <20121010063545.453368147@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 09 Oct 2012 23:35:45 -0700

> Revision to earlier patch set for vxlan, includes a couple
> more issues.

Applied, but that checksum issue is extremely unfortunate.

Why does postpull rcsum work for GRE but not VXLAN?
