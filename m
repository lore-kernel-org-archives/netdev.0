From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bnx2x: prevent incorrect byte-swap in BE
Date: Mon, 01 Sep 2014 17:54:33 -0700 (PDT)
Message-ID: <20140901.175433.1457594341835232647.davem@davemloft.net>
References: <1409234064-20619-1-git-send-email-Dmitry.Kravkov@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: Dmitry.Kravkov@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526AbaIBAye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 20:54:34 -0400
In-Reply-To: <1409234064-20619-1-git-send-email-Dmitry.Kravkov@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Date: Thu, 28 Aug 2014 16:54:23 +0300

> Fixes incorrectly defined struct in FW HSI for BE platform.
> Affects tunneling, tx-switching and anti-spoofing.
> 
> Introduced in e42780b66aab88d3a82b6087bcd6095b90eecde7
>     bnx2x: Utilize FW 7.10.51
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>

Applied.
