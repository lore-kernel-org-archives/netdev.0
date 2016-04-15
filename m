From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/hsr: Added support for HSR v1
Date: Fri, 15 Apr 2016 17:08:41 -0400 (EDT)
Message-ID: <20160415.170841.1808571255697438360.davem@davemloft.net>
References: <20160413115222.GA42572@aircraft-controller>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@alten.se, hannes@stressinduktion.org,
	sd@queasysnail.net, henrik@austad.us, nikolay@cumulusnetworks.com,
	tgraf@suug.ch, linville@tuxdriver.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, eranbe@mellanox.com, ast@plumgrid.com,
	netdev@vger.kernel.org, peter.heise@airbus.com
To: mail@pheise.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbcDOVIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 17:08:45 -0400
In-Reply-To: <20160413115222.GA42572@aircraft-controller>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Heise <mail@pheise.de>
Date: Wed, 13 Apr 2016 13:52:22 +0200

> This patch adds support for the newer version 1 of the HSR
> networking standard. Version 0 is still default and the new
> version has to be selected via iproute2.
> 
> Main changes are in the supervision frame handling and its
> ethertype field.
> 
> Signed-off-by: Peter Heise <peter.heise@airbus.com>

Applied.
