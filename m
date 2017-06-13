From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qed: fix dump of context data
Date: Tue, 13 Jun 2017 13:33:19 -0400 (EDT)
Message-ID: <20170613.133319.437740378210457511.davem@davemloft.net>
References: <1497345359-2193-1-git-send-email-Tomer.Tayar@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yuval.mintz@cavium.com
To: Tomer.Tayar@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45558 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752253AbdFMRdV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 13:33:21 -0400
In-Reply-To: <1497345359-2193-1-git-send-email-Tomer.Tayar@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomer Tayar <Tomer.Tayar@cavium.com>
Date: Tue, 13 Jun 2017 12:15:59 +0300

> Currently when dumping a context data only word number '1' is read for the
> entire context.
> 
> Fixes: c965db444629 ("qed: Add support for debug data collection")
> 
> Signed-off-by: Tomer Tayar <Tomer.Tayar@cavium.com>

Applied.
