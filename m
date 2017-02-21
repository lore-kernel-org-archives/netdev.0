From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bnxt_en: Fix probe and open bugs.
Date: Mon, 20 Feb 2017 21:59:43 -0500 (EST)
Message-ID: <20170220.215943.2125740965941756299.davem@davemloft.net>
References: <1487636718-21293-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46158 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751078AbdBUC7s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 21:59:48 -0500
In-Reply-To: <1487636718-21293-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Mon, 20 Feb 2017 19:25:15 -0500

> Fix 3 issues related to bnxt_init_one() and bnxt_open().  Don't probe
> bridge devices and fixup some error code paths.

Series applied, thanks Michael.
