From: Hannes Reinecke <hare@suse.de>
Subject: Re: [RFC 4/6] qedi: Add LL2 iSCSI interface for offload iSCSI.
Date: Wed, 19 Oct 2016 09:53:08 +0200
Message-ID: <6277acf8-d19a-2947-b88e-af4a6b33825d@suse.de>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com>
 <1476853273-22960-5-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: martin.petersen@oracle.com, jejb@linux.vnet.ibm.com,
        linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        Yuval.Mintz@cavium.com, QLogic-Storage-Upstream@cavium.com,
        Nilesh Javali <nilesh.javali@cavium.com>,
        Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>,
        Chad Dupuis <chad.dupuis@cavium.com>,
        Saurav Kashyap <saurav.kashyap@cavium.com>,
        Arun Easi <arun.easi@cavium.com>
To: manish.rangankar@cavium.com, lduncan@suse.com, cleech@redhat.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1476853273-22960-5-git-send-email-manish.rangankar@cavium.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/2016 07:01 AM, manish.rangankar@cavium.com wrote:
> From: Manish Rangankar <manish.rangankar@cavium.com>
> 
> This patch adds support for iscsiuio interface using Light L2 (LL2) qed
> interface.
> 
> Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
> Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
> Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
> Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
> Signed-off-by: Arun Easi <arun.easi@cavium.com>
> Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
> ---
>  drivers/scsi/qedi/qedi.h      |  73 +++++++++
>  drivers/scsi/qedi/qedi_main.c | 357 ++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 430 insertions(+)
> 
Reviewed-by: Hannes Reinecke <hare@suse.com>

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		   Teamlead Storage & Networking
hare@suse.de			               +49 911 74053 688
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: F. Imendörffer, J. Smithard, J. Guild, D. Upmanyu, G. Norton
HRB 21284 (AG Nürnberg)
