From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: synchronize VF representor names
 with NIC firmware
Date: Thu, 02 Nov 2017 17:04:20 +0900 (KST)
Message-ID: <20171102.170420.1118413653679801073.davem@davemloft.net>
References: <20171101231949.GA21755@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        vijaya.guvva@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45088 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755454AbdKBIEZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:04:25 -0400
In-Reply-To: <20171101231949.GA21755@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 1 Nov 2017 16:19:49 -0700

> From: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>
> 
> LiquidIO firmware supports a vswitch that needs to know the names of the
> VF representors in the host to maintain compatibility for direct
> programming using external Openflow agents.  So, for each VF representor,
> send its name to the firmware when it gets registered and when its name
> changes.
> 
> Signed-off-by: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, thank you.
