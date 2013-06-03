From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]] icmp: fix icmp_unreach() comment.
Date: Mon, 03 Jun 2013 00:27:38 -0700 (PDT)
Message-ID: <20130603.002738.128113162144981709.davem@davemloft.net>
References: <1370255005-3047-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3FCH1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:27:39 -0400
In-Reply-To: <1370255005-3047-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Mon,  3 Jun 2013 13:23:25 +0300

> ICMP_PARAMETERPROB is handled by icmp_unreach(); This patch adds
> ICMP_PARAMETERPROB to the list of ICMP message types handled by icmp_unreach().
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Good catch, applied, thanks Rami!
