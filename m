From: "Martin K. Petersen" <martin.petersen@oracle.com>
Subject: Re: qed, qedi patchset submission
Date: Mon, 14 Nov 2016 18:47:27 -0500
Message-ID: <yq11sydfwts.fsf@sermon.lab.mkp.net>
References: <alpine.LRH.2.00.1611141256340.28058@mvluser05.qlc.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
        David Miller <davem@davemloft.net>,
        <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>
To: Arun Easi <arun.easi@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45893 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754304AbcKNXrg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 18:47:36 -0500
In-Reply-To: <alpine.LRH.2.00.1611141256340.28058@mvluser05.qlc.com> (Arun
        Easi's message of "Mon, 14 Nov 2016 13:53:50 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Arun" == Arun Easi <arun.easi@cavium.com> writes:

Arun,

Arun> Do you have any preference or thoughts on how the "qed" patches be
Arun> approached? Just as a reference, our rdma driver "qedr" went
Arun> through something similar[1], and eventually "qed" patches were
Arun> taken by David in the net tree and "qedr", in the rdma tree
Arun> (obviously) by Doug L.

DaveM can queue the whole series or I can hold the SCSI pieces for
rc1. Either way works for me.

However, I would like to do a review of the driver first. I will try to
get it done this week.

-- 
Martin K. Petersen	Oracle Linux Engineering
