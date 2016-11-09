From: "Martin K. Petersen" <martin.petersen@oracle.com>
Subject: Re: [PATCH v2 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver framework.
Date: Tue, 08 Nov 2016 19:07:57 -0500
Message-ID: <yq1y40tplb6.fsf@sermon.lab.mkp.net>
References: <201611081805.KzpHTNxg%fengguang.wu@intel.com>
        <alpine.LRH.2.00.1611081129440.28058@mvluser05.qlc.com>
        <yq137j1r0q3.fsf@sermon.lab.mkp.net>
        <alpine.LRH.2.00.1611081555110.28058@mvluser05.qlc.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        kbuild test robot <lkp@intel.com>,
        Manish Rangankar <manish.rangankar@cavium.com>,
        <kbuild-all@01.org>, James Bottomley <jejb@linux.vnet.ibm.com>,
        <lduncan@suse.com>, <cleech@redhat.com>,
        <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>,
        <QLogic-Storage-Upstream@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: Arun Easi <arun.easi@cavium.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1611081555110.28058@mvluser05.qlc.com> (Arun
        Easi's message of "Tue, 8 Nov 2016 16:00:55 -0800")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Arun" == Arun Easi <arun.easi@cavium.com> writes:

>> It's fine to post the patches split up to ease the review
>> process. But whatever we commit must obviously be bisectable.

Arun> If it is alright with you, we would like to have all of our
Arun> initial patches for the driver (qedi) squashed as a single commit
Arun> to the tree. We will ensure that this single combined commit
Arun> compiles clean.

That's fine with me.

-- 
Martin K. Petersen	Oracle Linux Engineering
