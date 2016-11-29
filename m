From: "Martin K. Petersen" <martin.petersen@oracle.com>
Subject: Re: [PATCH v2 0/6] Add QLogic FastLinQ iSCSI (qedi) driver.
Date: Tue, 29 Nov 2016 12:21:55 -0500
Message-ID: <yq1k2bmmcb0.fsf@sermon.lab.mkp.net>
References: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <martin.petersen@oracle.com>, <lduncan@suse.com>,
        <cleech@redhat.com>, <linux-scsi@vger.kernel.org>,
        <netdev@vger.kernel.org>, <QLogic-Storage-Upstream@cavium.com>,
        <Yuval.Mintz@cavium.com>
To: Manish Rangankar <manish.rangankar@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:49462 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933266AbcK2RWu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 12:22:50 -0500
In-Reply-To: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
        (Manish Rangankar's message of "Mon, 7 Nov 2016 22:56:57 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Manish" == Manish Rangankar <manish.rangankar@cavium.com> writes:

Manish> This series introduces hardware offload iSCSI initiator driver
Manish> for the 41000 Series Converged Network Adapters (579xx chip) by
Manish> Qlogic. The overall driver design includes a common module
Manish> ('qed') and protocol specific dependent modules ('qedi' for
Manish> iSCSI).

The SCSI portions look reasonably sane to me.

Reviewed-by: Martin K. Petersen <martin.petersen@oracle.com>

-- 
Martin K. Petersen	Oracle Linux Engineering
