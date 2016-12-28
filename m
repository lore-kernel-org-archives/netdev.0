From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: add pr_debug for tracking asocs not
 found
Date: Wed, 28 Dec 2016 14:26:43 -0500 (EST)
Message-ID: <20161228.142643.301838823990974094.davem@davemloft.net>
References: <2e7482596bbf75efb56e313e33179f9e1c0e6996.1482924698.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        vyasevich@gmail.com, nhorman@tuxdriver.com, lucien.xin@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44128 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbcL1T1v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 14:27:51 -0500
In-Reply-To: <2e7482596bbf75efb56e313e33179f9e1c0e6996.1482924698.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed, 28 Dec 2016 09:51:56 -0200

> This pr_debug may help identify why the system is generating some
> Aborts. It's not something a sysadmin would be expected to use.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
