From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: export netlink_diag.h header
Date: Wed, 19 Jun 2013 18:30:42 -0700 (PDT)
Message-ID: <20130619.183042.1516025180452122503.davem@davemloft.net>
References: <20130619180654.09e6a3e1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avagin@openvz.org, netdev@vger.kernel.org, kaber@trash.net
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47105 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935297Ab3FTBan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 21:30:43 -0400
In-Reply-To: <20130619180654.09e6a3e1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 19 Jun 2013 18:06:54 -0700

> The netlink_diag.h is in include/uapi/linux but not in the Kbuild necessary
> to cause it to be exported by make headers_install.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied and queued up for -stable, thanks.
