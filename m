From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: add missing lock in ping_v6_sendmsg
Date: Wed, 03 Jul 2013 17:42:26 -0700 (PDT)
Message-ID: <20130703.174226.864619645935747700.davem@davemloft.net>
References: <1372866769-11219-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932424Ab3GDAm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 20:42:27 -0400
In-Reply-To: <1372866769-11219-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Thu,  4 Jul 2013 00:52:49 +0900

> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied.
