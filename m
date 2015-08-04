From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] lwtunnel: encap locally-generated ipv4
 packets
Date: Mon, 03 Aug 2015 22:26:27 -0700 (PDT)
Message-ID: <20150803.222627.1404054693023438503.davem@davemloft.net>
References: <1438619961-15919-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com, tgraf@suug.ch,
	roopa@cumulusnetworks.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbbHDF02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:26:28 -0400
In-Reply-To: <1438619961-15919-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Mon, 3 Aug 2015 17:39:19 +0100

> Locally-generated IPv4 packets, such as from applications running on
> the host or traceroute/ping currently don't have lwtunnel output
> redirected encap applied. However, they should do in the same way as
> for forwarded packets and this patch series addresses that.

Series applied, thanks.
