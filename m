From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] mpls: fixes for nexthops without via addresses
Date: Sat, 12 Dec 2015 00:44:21 -0500 (EST)
Message-ID: <20151212.004421.1597066518363711281.davem@davemloft.net>
References: <1449775851-20758-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, roopa@cumulusnetworks.com,
	netdev@vger.kernel.org, sam.h.russell@gmail.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34385 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbbLLFoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 00:44:23 -0500
In-Reply-To: <1449775851-20758-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Thu, 10 Dec 2015 19:30:47 +0000

> These four fixes all apply to the case of having an mpls route with an
> output device, but without a nexthop.

Series applied, thanks.
