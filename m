From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: rename dev to orig_dev in
 deliver_ptype_list_skb
Date: Tue, 31 Mar 2015 16:37:58 -0400 (EDT)
Message-ID: <20150331.163758.2027750392690625070.davem@davemloft.net>
References: <1427727361-3138-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953AbbCaUh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 16:37:59 -0400
In-Reply-To: <1427727361-3138-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 30 Mar 2015 16:56:01 +0200

> Unlike other places, this function uses name "dev" for what should be
> "orig_dev", which might be a bit confusing. So fix this.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks Jiri.
