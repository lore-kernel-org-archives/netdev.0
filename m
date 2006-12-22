From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 0/10] cxgb3: Chelsio T3 1G/10G ethernet device driver
Date: Thu, 21 Dec 2006 23:19:32 -0800
Message-ID: <458B8704.6060607@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1945966AbWLVHTq@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

I resubmit the patch supporting the latest Chelsio T3 adapter.
It incorporates Arjan's feedbacks:
- remove unnecessary ifdefs
- updates the pci ressource managment
- add flush after register write.

It is built against Linus'tree.

A corresponding monolithic patch is available at this URL:
http://service.chelsio.com/kernel.org/cxgb3.patch.bz2

This driver is required by the Chelsio T3 RDMA driver
which was updated on 12/20/2006.

Cheers,
Divy
