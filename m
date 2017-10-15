From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/6] bnxt_en: bug fixes.
Date: Sat, 14 Oct 2017 18:52:07 -0700 (PDT)
Message-ID: <20171014.185207.1094199524602291441.davem@davemloft.net>
References: <1507943374-13308-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38470 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751165AbdJOBwI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 21:52:08 -0400
In-Reply-To: <1507943374-13308-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Fri, 13 Oct 2017 21:09:28 -0400

> Various bug fixes for the VF/PF link change logic, VF resource checking,
> potential firmware response corruption on NVRAM and DCB parameters,
> and reading the wrong register for PCIe link speed on the VF.

Series applied, thanks.
