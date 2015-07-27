From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwtunnel: export linux/lwtunnel.h to userspace
Date: Sun, 26 Jul 2015 21:46:14 -0700 (PDT)
Message-ID: <20150726.214614.1861526312474581779.davem@davemloft.net>
References: <1437659036-14282-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, roopa@cumulusnetworks.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbbG0EqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 00:46:20 -0400
In-Reply-To: <1437659036-14282-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 23 Jul 2015 15:43:56 +0200

> Note also that include/linux/lwtunnel.h is not needed.
> 
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Fixes: 499a24256862 ("lwtunnel: infrastructure for handling light weight tunnels like mpls")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
