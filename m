From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xgene Remove xgene specific phy and MAC lookup
 functions
Date: Thu, 20 Aug 2015 14:44:13 -0700 (PDT)
Message-ID: <20150820.144413.1974731630647229857.davem@davemloft.net>
References: <1440010602-5860-1-git-send-email-jeremy.linton@arm.com>
	<1440010602-5860-2-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, stripathi@apm.com, kchudgar@apm.com,
	brian.brooks.arm@vger.kernel.org, netdev@vger.kernel.org
To: jeremy.linton@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbbHTVoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:44:14 -0400
In-Reply-To: <1440010602-5860-2-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Linton <jeremy.linton@arm.com>
Date: Wed, 19 Aug 2015 13:56:42 -0500

> Convert the xgene_get_mac_address to device_get_mac_address(), and
> xgene_get_phy_mode() to device_get_phy_mode().
> 
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>

Applied, thanks Jeremy.
