From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: macb: Fix 64 bit addressing support for GEM
Date: Sun, 29 Jan 2017 18:26:47 -0500 (EST)
Message-ID: <20170129.182647.403395983905752501.davem@davemloft.net>
References: <1485529700-26171-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, harinikatakamlinux@gmail.com
To: rafalo@cadence.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750798AbdA2X1e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 18:27:34 -0500
In-Reply-To: <1485529700-26171-1-git-send-email-rafalo@cadence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafal Ozieblo <rafalo@cadence.com>
Date: Fri, 27 Jan 2017 15:08:20 +0000

> This patch adds support for 32 bit GEM in
> 64 bit system. It checks capability at runtime
> and uses appropriate buffer descriptor.
> 
> Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>

Applied, thank you.
