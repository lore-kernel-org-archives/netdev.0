From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 00/11] qed*: Add XDP support
Date: Wed, 30 Nov 2016 14:32:21 -0500 (EST)
Message-ID: <20161130.143221.1609717089304684754.davem@davemloft.net>
References: <1480430830-17671-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753657AbcK3TcX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:32:23 -0500
In-Reply-To: <1480430830-17671-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@cavium.com>
Date: Tue, 29 Nov 2016 16:46:59 +0200

> This patch series is intended to add XDP to the qede driver, although
> it contains quite a bit of cleanups, refactorings and infrastructure
> changes as well.
> 
> The content of this series can be roughly divided into:
> 
>  - Datapath improvements - mostly focused on having the datapath utilize
> parameters which can be more tightly contained in cachelines.
> Patches #1, #2, #8, #9 belong to this group.
> 
>  - Refactoring - done mostly in favour of XDP. Patches #3, #4, #5, #9.
> 
>  - Infrastructure changes - done in favour of XDP. Paches #6 and #7 belong
> to this category [#7 being by far the biggest patch in the series].
> 
>  - Actual XDP support - last two patches [#10, #11].

Series applied, thank you.
