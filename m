From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: bump up driver version to match
 newer NIC firmware
Date: Sat, 29 Jul 2017 15:21:34 -0700 (PDT)
Message-ID: <20170729.152134.665519090725321593.davem@davemloft.net>
References: <20170727193228.GA1918@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42860 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751632AbdG2WVi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 18:21:38 -0400
In-Reply-To: <20170727193228.GA1918@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 27 Jul 2017 12:32:28 -0700

> Bump up driver version to match newer NIC firmware.  Also update
> nic_rx_stats (a struct common to host driver and firmware) by adding a new
> field:  fw_total_fwd_bytes.
> 
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>

Applied, thanks.
