From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 0/4] Add Broadcom bnx2i iSCSI driver.
Date: Mon, 8 Jun 2009 18:14:40 -0700
Message-ID: <1244510084-4457-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com,
	netdev@vger.kernel.org, anilgv@broadcom.com, benli@broadcom.com
To: James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu,
	davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


James, I've re-spinned the bnx2i patchset for scsi-misc-2.6.
Compared to the patchset sent on 5/23, we've converted some
remaining kmalloc() to kzalloc().  And we have fixed up some
locking and style issues in the bnx2i driver that Mike has
uncovered.

Please consider applying them to scsi-misc-2.6.

Thanks.

