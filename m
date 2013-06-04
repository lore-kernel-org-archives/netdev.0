From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] Kconfig: remove dangling references to
 the deleted file
Date: Tue, 04 Jun 2013 15:19:21 -0700 (PDT)
Message-ID: <20130604.151921.1968513629312826458.davem@davemloft.net>
References: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
	<1370139797-8912-3-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971Ab3FDWTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 18:19:22 -0400
In-Reply-To: <1370139797-8912-3-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Sat,  1 Jun 2013 20:23:17 -0600

> Commit 202dc3fc599c1dded235d3b448d9ca924252e354 (Documentation: remove
> obsolete networking/multicast.txt file) deleted the obsolete file. After
> the file has been removed, clean up a couple of places where references
> to the deleted file were made so that users wouldn't be confused when
> they consult the Help menu.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>

Applied.
