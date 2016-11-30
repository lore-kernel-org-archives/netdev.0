From: "Martin K. Petersen" <martin.petersen@oracle.com>
Subject: Re: qed, qedi patchset submission
Date: Wed, 30 Nov 2016 11:45:41 -0500
Message-ID: <yq1oa0wj4qy.fsf@sermon.lab.mkp.net>
References: <alpine.LRH.2.00.1611141256340.28058@mvluser05.qlc.com>
        <yq11sydfwts.fsf@sermon.lab.mkp.net>
        <alpine.LRH.2.00.1611291452030.28058@mvluser05.qlc.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>
To: Arun Easi <arun.easi@cavium.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1611291452030.28058@mvluser05.qlc.com> (Arun
        Easi's message of "Tue, 29 Nov 2016 15:11:26 -0800")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Arun" == Arun Easi <arun.easi@cavium.com> writes:

Arun,

Arun> So far, we have been posting qedi changes split into functional
Arun> blocks, for review, but was not bisectable. With Martin ok to our
Arun> request to squash all patches while committing to tree, we were
Arun> wondering if we should post the qedi patches squashed, with all
Arun> the Reviewed-by added, or continue to post as before?

I guess it depends how things can be split up in a bisectable fashion.

If the net/ pieces can be completely separated from the scsi/ pieces
maybe it would be best to have two patches?

-- 
Martin K. Petersen	Oracle Linux Engineering
