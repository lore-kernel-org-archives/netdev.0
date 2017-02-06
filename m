From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1] net-next: treewide use is_vlan_dev() helper function.
Date: Mon, 06 Feb 2017 16:35:43 -0500 (EST)
Message-ID: <20170206.163543.1507099447218540784.davem@davemloft.net>
References: <1486227649-12648-1-git-send-email-parav@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, monis@mellanox.com, santosh@chelsio.com,
        ganeshgr@chelsio.com, manish.chopra@cavium.com,
        rahul.verma@cavium.com, Dept-GELinuxNICDev@cavium.com,
        harish.patil@cavium.com, kys@microsoft.com, haiyangz@microsoft.com,
        sthemmin@microsoft.com, QLogic-Storage-Upstream@qlogic.com,
        jejb@linux.vnet.ibm.com, martin.petersen@oracle.com,
        jth@kernel.org, arvid.brodin@alten.se, leon@kernel.org,
        sagi@grimberg.me, swise@opengridcomputing.com,
        bart.vanassche@sandisk.com, valex@mellanox.com, arnd@arndb.de,
        weiyj.lk@gmail.com, jmaxwell37@gmail.com, varun@chelsio.com,
        jbenc@redhat.com, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, devel@linuxdriverproject.org,
        linux-scsi@vger.kernel.org, fcoe-devel@open-fcoe.org
To: parav@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49252 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdBFVfr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:35:47 -0500
In-Reply-To: <1486227649-12648-1-git-send-email-parav@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parav Pandit <parav@mellanox.com>
Date: Sat,  4 Feb 2017 11:00:49 -0600

> This patch makes use of is_vlan_dev() function instead of flag
> comparison which is exactly done by is_vlan_dev() helper function.
> 
> Signed-off-by: Parav Pandit <parav@mellanox.com>
> Reviewed-by: Daniel Jurgens <danielj@mellanox.com>

Applied.
