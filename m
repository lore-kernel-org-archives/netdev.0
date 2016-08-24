From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ena: change the return type of
 ena_set_push_mode() to be void.
Date: Tue, 23 Aug 2016 17:43:04 -0700 (PDT)
Message-ID: <20160823.174304.418891447171997989.davem@davemloft.net>
References: <1471972817-4103-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netanel@annapurnalabs.com
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56137 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753525AbcHXAng (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 20:43:36 -0400
In-Reply-To: <1471972817-4103-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Tue, 23 Aug 2016 20:20:17 +0300

> This patch changes the return type of ena_set_push_mode() to be void,
> as it always returns 0.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
