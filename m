From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 v3 resend] 6lowpan: minor fixes
Date: Mon, 25 Jun 2012 16:45:27 -0700 (PDT)
Message-ID: <20120625.164527.1149743351132555947.davem@davemloft.net>
References: <1340632143-27794-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56726 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757873Ab2FYXp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 19:45:27 -0400
In-Reply-To: <1340632143-27794-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Mon, 25 Jun 2012 17:49:00 +0400

> I sent this set several weeks ago and seems that it was missed
> (or please let me know if there was a reason).
> 
> this is the 3-rd version of the patches.
> Changes since v2:
>  - Removed WARN_ON() and BUG() from skb fetch methods. That wasn't a good idea
>    to crash kernel by such an unsignificant issue.
>  - Added new patch (I've decided to add it here just to keep all the 6lowpan
>    related code together)

All applied, thanks.
