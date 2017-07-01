From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/9] introduce flower offload capabilities
Date: Sat, 01 Jul 2017 08:52:00 -0700 (PDT)
Message-ID: <20170701.085200.1480396196977417459.davem@davemloft.net>
References: <1498766899-30707-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com, gerlitz.or@gmail.com,
        pieter.jansenvanvuuren@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751389AbdGAPwF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 11:52:05 -0400
In-Reply-To: <1498766899-30707-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Thu, 29 Jun 2017 22:08:10 +0200

> this series adds flower offload to the NFP driver. It builds on recent
> work to add representor and a skeleton flower app - now the app does what
> its name says.
> 
> In general the approach taken is to allow some flows within
> the universe of possible flower matches and tc actions to be offloaded.
> It is planned that this support will grow over time but the support
> offered by this patch-set seems to be a reasonable starting point.
> 
> Key Changes since v2:
> * Revised flow structures to simplify setup/teardown and locking of stats
> * Addressed other code-change review of v2
> 
> Other review questions regarding v2 have been answered on netdev.

Series applied, thanks Simon.
