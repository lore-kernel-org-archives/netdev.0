From: "Martin K. Petersen" <martin.petersen@oracle.com>
Subject: Re: [PATCH v2 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver framework.
Date: Tue, 08 Nov 2016 18:49:40 -0500
Message-ID: <yq137j1r0q3.fsf@sermon.lab.mkp.net>
References: <201611081805.KzpHTNxg%fengguang.wu@intel.com>
        <alpine.LRH.2.00.1611081129440.28058@mvluser05.qlc.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kbuild test robot <lkp@intel.com>,
        Manish Rangankar <manish.rangankar@cavium.com>,
        <kbuild-all@01.org>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        James Bottomley <jejb@linux.vnet.ibm.com>, <lduncan@suse.com>,
        <cleech@redhat.com>, <linux-scsi@vger.kernel.org>,
        <netdev@vger.kernel.org>, <QLogic-Storage-Upstream@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: Arun Easi <arun.easi@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38350 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbcKHXuI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 18:50:08 -0500
In-Reply-To: <alpine.LRH.2.00.1611081129440.28058@mvluser05.qlc.com> (Arun
        Easi's message of "Tue, 8 Nov 2016 12:04:48 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Arun" == Arun Easi <arun.easi@cavium.com> writes:

Arun,

Arun> qedi is the new iSCSI driver, which we are trying to submit, for
Arun> our 41000 series CNA. This patch series were broken up into
Arun> logical blocks for review purpose, but were not made to compile
Arun> individually. It is our impression that this is acceptable for
Arun> SCSI and all the initial "qedi" patches will be squashed and
Arun> committed as a single commit. Please let us know if we are
Arun> mistaken, and if so, we will post another series with this taken
Arun> care of.

It's fine to post the patches split up to ease the review process. But
whatever we commit must obviously be bisectable.

-- 
Martin K. Petersen	Oracle Linux Engineering
