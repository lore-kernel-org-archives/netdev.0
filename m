From: Arun Easi <arun.easi@cavium.com>
Subject: Re: [PATCH v2 3/6] qedi: Add QLogic FastLinQ offload iSCSI driver
 framework.
Date: Tue, 8 Nov 2016 16:00:55 -0800
Message-ID: <alpine.LRH.2.00.1611081555110.28058@mvluser05.qlc.com>
References: <201611081805.KzpHTNxg%fengguang.wu@intel.com> <alpine.LRH.2.00.1611081129440.28058@mvluser05.qlc.com> <yq137j1r0q3.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: kbuild test robot <lkp@intel.com>,
        Manish Rangankar <manish.rangankar@cavium.com>,
        <kbuild-all@01.org>, James Bottomley <jejb@linux.vnet.ibm.com>,
        <lduncan@suse.com>, <cleech@redhat.com>,
        <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>,
        <QLogic-Storage-Upstream@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <yq137j1r0q3.fsf@sermon.lab.mkp.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin,

On Tue, 8 Nov 2016, 3:49pm -0000, Martin K. Petersen wrote:

> >>>>> "Arun" == Arun Easi <arun.easi@cavium.com> writes:
> 
> Arun,
> 
> Arun> qedi is the new iSCSI driver, which we are trying to submit, for
> Arun> our 41000 series CNA. This patch series were broken up into
> Arun> logical blocks for review purpose, but were not made to compile
> Arun> individually. It is our impression that this is acceptable for
> Arun> SCSI and all the initial "qedi" patches will be squashed and
> Arun> committed as a single commit. Please let us know if we are
> Arun> mistaken, and if so, we will post another series with this taken
> Arun> care of.
> 
> It's fine to post the patches split up to ease the review process. But
> whatever we commit must obviously be bisectable.
> 

If it is alright with you, we would like to have all of our initial 
patches for the driver (qedi) squashed as a single commit to the tree. We 
will ensure that this single combined commit compiles clean.

Regards,
-Arun
