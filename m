From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] sctp: a bunch of fixes for processing dupcookie
Date: Wed, 24 May 2017 15:22:57 -0400 (EDT)
Message-ID: <20170524.152257.2090892064722032542.davem@davemloft.net>
References: <cover.1495517205.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935083AbdEXTXF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 15:23:05 -0400
In-Reply-To: <cover.1495517205.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 23 May 2017 13:28:53 +0800

> After introducing transport hashtable and per stream info into sctp,
> some regressions were caused when processing dupcookie, this patchset
> is to fix them.

Series applied, thanks.
