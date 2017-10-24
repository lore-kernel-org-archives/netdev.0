From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next] liquidio: pass date and time info to NIC
 firmware
Date: Tue, 24 Oct 2017 18:57:32 +0900 (KST)
Message-ID: <20171024.185732.249303077547012231.davem@davemloft.net>
References: <20171024033325.GA17455@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751998AbdJXJ5g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:57:36 -0400
In-Reply-To: <20171024033325.GA17455@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 23 Oct 2017 20:33:25 -0700

> From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
> 
> Pass date and time information to NIC at the time of loading
> firmware and periodically update the host time to NIC firmware.
> This is to make NIC firmware use the same time reference as Host,
> so that it is easy to correlate logs from firmware and host for debugging.
> 
> Signed-off-by: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
