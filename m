From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnxt_en: Fix randconfig build errors.
Date: Sat, 28 Oct 2017 18:24:35 +0900 (KST)
Message-ID: <20171028.182435.2090697905394540428.davem@davemloft.net>
References: <1509170170-14847-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kubakici@wp.pl, netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33664 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751298AbdJ1JYu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 05:24:50 -0400
In-Reply-To: <1509170170-14847-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Sat, 28 Oct 2017 01:56:10 -0400

> Fix undefined symbols when CONFIG_VLAN_8021Q or CONFIG_INET is not set.
> 
> Fixes: 8c95f773b4a3 ("bnxt_en: add support for Flower based vxlan encap/decap offload")
> Reported-by: Jakub Kicinski <kubakici@wp.pl>
> Signed-off-by: Michael Chan <michael.chan@broadcom.com>

Applied, thanks Michael.
