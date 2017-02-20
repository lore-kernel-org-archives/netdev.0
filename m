From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sctp: support MSG_MORE flag when sending
 msg
Date: Mon, 20 Feb 2017 10:26:23 -0500 (EST)
Message-ID: <20170220.102623.1083491050369297552.davem@davemloft.net>
References: <cover.1487440272.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com, david.laight@aculab.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38404 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753802AbdBTP0a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:26:30 -0500
In-Reply-To: <cover.1487440272.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sun, 19 Feb 2017 01:52:44 +0800

> This patch is to add support for MSG_MORE on sctp. Patch 1/2 is an
> improvement ahead of patch 2/2 to solve the close block problem
> mentioned in https://patchwork.ozlabs.org/patch/372404/.

Series applied, thanks Xin.
