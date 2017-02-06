From: Johannes Thumshirn <jth@kernel.org>
Subject: Re: [PATCHv1] net-next: treewide use is_vlan_dev() helper function.
Date: Mon, 6 Feb 2017 08:31:45 +0100
Message-ID: <5a1feeae-5c59-0930-e387-8352cf36018f@kernel.org>
References: <1486227649-12648-1-git-send-email-parav@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Parav Pandit <parav@mellanox.com>, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com, monis@mellanox.com,
        santosh@chelsio.com, ganeshgr@chelsio.com,
        manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, harish.patil@cavium.com,
        kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        QLogic-Storage-Upstream@qlogic.com, jejb@linux.vnet.ibm.com,
        martin.petersen@oracle.com, arvid.brodin@alten.se,
        davem@davemloft.net, leon@kernel.org, sagi@grimberg.me,
        swise@opengridcomputing.com, bart.vanassche@sandisk.com,
        valex@mellanox.com, arnd@arndb.de, weiyj.lk@gmail.com,
        jmaxwell37@gmail.com, varun@chelsio.com, jbenc@redhat.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        devel@linuxdriverproject.org, linux-scsi@vger.kernel.org,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33397 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750879AbdBFHbt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 02:31:49 -0500
In-Reply-To: <1486227649-12648-1-git-send-email-parav@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 02/04/2017 06:00 PM, Parav Pandit wrote:
> This patch makes use of is_vlan_dev() function instead of flag
> comparison which is exactly done by is_vlan_dev() helper function.
>
> Signed-off-by: Parav Pandit <parav@mellanox.com>
> Reviewed-by: Daniel Jurgens <danielj@mellanox.com>
> ---
>

For drivers/scsi/fcoe/fcoe.c:
Acked-by: Johannes Thumshirn <jth@kernel.org>
