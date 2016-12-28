From: Hannes Reinecke <hare@suse.de>
Subject: Re: [Open-FCoE] [PATCH RFC 4/5] qedf: Add offload ELS request
 handling.
Date: Wed, 28 Dec 2016 10:10:01 +0100
Message-ID: <d43070fc-8aff-bdde-4e90-d39a01289069@suse.de>
References: <1482520628-24207-1-git-send-email-chad.dupuis@cavium.com>
 <1482520628-24207-5-git-send-email-chad.dupuis@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: fcoe-devel@open-fcoe.org, netdev@vger.kernel.org,
        QLogic-Storage-Upstream@cavium.com, linux-scsi@vger.kernel.org,
        yuval.mintz@cavium.com
To: "Dupuis, Chad" <chad.dupuis@cavium.com>, martin.petersen@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45182 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751103AbcL1JKE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Dec 2016 04:10:04 -0500
In-Reply-To: <1482520628-24207-5-git-send-email-chad.dupuis@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/2016 08:17 PM, Dupuis, Chad wrote:
> From: "Dupuis, Chad" <chad.dupuis@cavium.com>
> 
> This patch adds support for ELS requests that are handled by the firmware for
> offloaded sessions.
> 
> Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
> Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
> Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
> Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
> ---
>  drivers/scsi/qedf/qedf_els.c | 984 +++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 984 insertions(+)
>  create mode 100644 drivers/scsi/qedf/qedf_els.c
> 
Reviewed-by: Hannes Reinecke <hare@suse.com>

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		      zSeries & Storage
hare@suse.de			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: J. Hawn, J. Guild, F. Imendörffer, HRB 16746 (AG Nürnberg)
