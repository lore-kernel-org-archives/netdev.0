From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] net: add netdev_lockdep_set_classes()
 helper
Date: Thu, 09 Jun 2016 00:03:11 -0700 (PDT)
Message-ID: <20160609.000311.56592409437897501.davem@davemloft.net>
References: <1465430127-22993-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42220 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161015AbcFIHDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 03:03:12 -0400
In-Reply-To: <1465430127-22993-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed,  8 Jun 2016 16:55:24 -0700

> It is time to add netdev_lockdep_set_classes() helper
> so that lockdep annotations per device type are easier to manage.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
