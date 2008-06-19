From: "Karen Xie" <kxie@chelsio.com>
Subject: [PATCH 0/3 2.6.27] cxgb3i: Add iSCSI driver
Date: Wed, 18 Jun 2008 22:10:00 -0700
Message-ID: <8A71B368A89016469F72CD08050AD334D7128B@maui.asicdesigners.com>
References: <8A71B368A89016469F72CD08050AD334D71285@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<open-iscsi@googlegroups.com>, <linux-kernel@vger.kernel.org>,
	<security@kernel.org>
To: <michaelc@cs.wisc.edu>, "Divy Le Ray" <divy@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please review the iSCSI drivers for Chelsio CXGB3 (S3XX) devices.  

Here is a brief description of the patch series:
- added iscsi support to cxgb3 driver
- added pdu digest offload and payload direct-placement support to open-iscsi
- the cxgb3i iscsi driver

Thanks.

















