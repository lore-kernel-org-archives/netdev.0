From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4: add support for linkdown sysctl to
 netconf
Date: Wed, 08 Jul 2015 23:35:18 -0700 (PDT)
Message-ID: <20150708.233518.1183230585329752905.davem@davemloft.net>
References: <1436291817-1555-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbbGIGfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 02:35:21 -0400
In-Reply-To: <1436291817-1555-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Tue,  7 Jul 2015 13:56:57 -0400

> This kernel patch exports the value of the new
> ignore_routes_with_linkdown via netconf.
> 
> v2: changes to notify userspace via netlink when sysctl values change
> and proposed for 'net' since this could be considered a bugfix
> 
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Suggested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied to net, thanks.
