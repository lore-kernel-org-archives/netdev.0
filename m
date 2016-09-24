From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 0/5] mlx4 VF vlan protocol 802.1ad support
Date: Sat, 24 Sep 2016 08:11:56 -0400 (EDT)
Message-ID: <20160924.081156.797265969084360323.davem@davemloft.net>
References: <1474535476-10662-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, moshe@mellanox.com,
        ogerlitz@mellanox.com, john.fastabend@gmail.com,
        ariel.elior@qlogic.com, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, sriharsha.basavapatna@broadcom.com,
        somnath.kotur@broadcom.com, jeffrey.t.kirsher@intel.com,
        saeedm@mellanox.com, Yuval.Mintz@qlogic.com,
        Dept-GELinuxNICDev@qlogic.com, linux-net-drivers@solarflare.com,
        ecree@solarflare.com, bkenward@solarflare.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36706 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750838AbcIXMME (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 08:12:04 -0400
In-Reply-To: <1474535476-10662-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu, 22 Sep 2016 12:11:11 +0300

> This patchset adds VF VLAN protocol 802.1ad support to the
> mlx4 driver.
> We extended the VF VLAN API with an additional parameter
> for VLAN protocol, and kept 802.1Q as drivers' default.
> 
> We prepared a userspace support (ip link tool).
> The patch will be submitted to the iproute2 mailing list.
> 
> The ip link tool VF VLAN protocol parameter is optional (default: 802.1Q).
> A configuration command of VF VLAN that is used prior to this patchset
> will result in same functionality as today's (VST with VLAN protocol 802.1Q).
> 
> The series generated against net-next commit:
> 688dc5369a63 "Merge branch 'mlx4-next'"
> 
> All maintainers of the modified modules are in cc.

Series applied, thanks.
