From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] PTP support for macb driver
Date: Mon, 19 Jun 2017 14:29:04 -0400 (EDT)
Message-ID: <20170619.142904.999832065115889532.davem@davemloft.net>
References: <1497614298-14074-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, richardcochran@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        harini.katakam@xilinx.com, andrei.pistirica@microchip.com
To: rafalo@cadence.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36492 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdFSS3G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 14:29:06 -0400
In-Reply-To: <1497614298-14074-1-git-send-email-rafalo@cadence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafal Ozieblo <rafalo@cadence.com>
Date: Fri, 16 Jun 2017 12:58:18 +0100

> This patch series adds support for PTP synchronization protocol
> in Cadence GEM driver based on PHC.

This doesn't apply cleanly to net-next, please respin.
