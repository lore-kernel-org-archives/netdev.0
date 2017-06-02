From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlcnic: Fix tunnel offload for 82xx adapters
Date: Fri, 02 Jun 2017 14:31:40 -0400 (EDT)
Message-ID: <20170602.143140.247835601286739365.davem@davemloft.net>
References: <20170602135254.3591-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@cavium.com
To: manish.chopra@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdFBSbm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:31:42 -0400
In-Reply-To: <20170602135254.3591-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@cavium.com>
Date: Fri, 2 Jun 2017 06:52:54 -0700

> Qlogic's 82xx series adapter doesn't support
> tunnel offloads, driver incorrectly assumes that it is
> supported and causes firmware hang while running tunnel IO.
> 
> This patch fixes this by not advertising tunnel offloads
> for 82xx adapters.
> 
> Signed-off-by: Manish Chopra <manish.chopra@cavium.com>

Applied, thank you.
