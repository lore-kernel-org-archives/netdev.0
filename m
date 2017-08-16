From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: update VF's netdev->max_mtu if
 there's a change in PF's MTU
Date: Wed, 16 Aug 2017 11:08:09 -0700 (PDT)
Message-ID: <20170816.110809.1823402769003505311.davem@davemloft.net>
References: <20170815232622.GA2385@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751847AbdHPSIJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 14:08:09 -0400
In-Reply-To: <20170815232622.GA2385@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 15 Aug 2017 16:26:22 -0700

> From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
> 
> A VF's MTU is capped at the parent PF's MTU.  So if there's a change in the
> PF's MTU, then update the VF's netdev->max_mtu.
> 
> Also remove duplicate log messages for MTU change.
> 
> Signed-off-by: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, thanks.
