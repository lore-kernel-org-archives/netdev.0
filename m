From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCHv1] net-next: treewide use is_vlan_dev() helper function.
Date: Mon, 6 Feb 2017 21:21:00 +0000
Message-ID: <BLUPR03MB1412D00046029D435FA40365CA400@BLUPR03MB1412.namprd03.prod.outlook.com>
References: <1486227649-12648-1-git-send-email-parav@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Parav Pandit <parav@mellanox.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        "hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>,
        "monis@mellanox.com" <monis@mellanox.com>,
        "santosh@chelsio.com" <santosh@chelsio.com>,
        "ganeshgr@chelsio.com" <ganeshgr@chelsio.com>,
        "manish.chopra@cavium.com" <manish.chopra@cavium.com>,
        "rahul.verma@cavium.com" <rahul.verma@cavium.com>,
        "Dept-GELinuxNICDev@cavium.com" <Dept-GELinuxNICDev@cavium.com>,
        "harish.patil@cavium.com" <harish.patil@cavium.com>,
        KY Srinivasan <kys@microsoft.com>,
        "Stephen Hemminger" <sthemmin@microsoft.com>,
        "QLogic-Storage-Upstream@qlogic.com"
        <QLogic-Storage-Upstream@qlogic.com>,
        "jejb@linux.vnet.ibm.com" <jejb@linux.vnet.ibm.com>,
        "martin.petersen@oracle.com"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0112.outbound.protection.outlook.com ([104.47.42.112]:16860
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751784AbdBFVVY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 16:21:24 -0500
In-Reply-To: <1486227649-12648-1-git-send-email-parav@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Parav Pandit [mailto:parav@mellanox.com]
> Sent: Saturday, February 4, 2017 12:01 PM
> To: dledford@redhat.com; Sean Hefty <sean.hefty@intel.com>;
> hal.rosenstock@gmail.com; monis@mellanox.com; santosh@chelsio.com;
> ganeshgr@chelsio.com; manish.chopra@cavium.com; rahul.verma@cavium.com;
> Dept-GELinuxNICDev@cavium.com; harish.patil@cavium.com; KY Srinivasan
> <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>; Stephen
> Hemminger <sthemmin@microsoft.com>; QLogic-Storage-Upstream@qlogic.com;
> jejb@linux.vnet.ibm.com; martin.petersen@oracle.com; jth@kernel.org;
> arvid.brodin@alten.se; davem@davemloft.net; leon@kernel.org;
> sagi@grimberg.me; swise@opengridcomputing.com;
> bart.vanassche@sandisk.com; valex@mellanox.com; arnd@arndb.de;
> weiyj.lk@gmail.com; jmaxwell37@gmail.com; varun@chelsio.com;
> jbenc@redhat.com; linux-rdma@vger.kernel.org; netdev@vger.kernel.org;
> devel@linuxdriverproject.org; linux-scsi@vger.kernel.org; fcoe-
> devel@open-fcoe.org
> Cc: Parav Pandit <parav@mellanox.com>
> Subject: [PATCHv1] net-next: treewide use is_vlan_dev() helper function.
>=20
> This patch makes use of is_vlan_dev() function instead of flag
> comparison which is exactly done by is_vlan_dev() helper function.
>=20
> Signed-off-by: Parav Pandit <parav@mellanox.com>
> Reviewed-by: Daniel Jurgens <danielj@mellanox.com>


For drivers/net/hyperv/netvsc_drv.c
Acked-by: Haiyang Zhang <haiyangz@microsoft.com>


Thanks.
