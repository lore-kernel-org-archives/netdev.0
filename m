From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: addr IFLA_OPERSTATE to netlink message
 for ipv6 ifinfo
Date: Thu, 13 Aug 2015 22:35:52 -0700 (PDT)
Message-ID: <20150813.223552.31424816194826779.davem@davemloft.net>
References: <1439493995-1079-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41657 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbbHNFfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 01:35:55 -0400
In-Reply-To: <1439493995-1079-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Thu, 13 Aug 2015 15:26:35 -0400

> This is useful information to include in ipv6 netlink messages that
> report interface information.  IFLA_OPERSTATE is already included in
> ipv4 messages, but missing for ipv6.  This closes that gap.
> 
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>

Applied, thanks Andy.
