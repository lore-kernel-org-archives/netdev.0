From: divy@chelsio.com
Subject: [PATCH 0/13] cxgb3 - driver updates
Date: Fri, 10 Aug 2007 23:51:08 -0700
Message-ID: <200708110651.l7B6p8v2008685@speedy5.asicdesigners.com>
Cc: linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: jeff@garzik.org, netdev@vget.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757954AbXHKGvX@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

I'm submitting a patch series for inclusion in netdev#upstream.

Here is a brief description:
-	MAC hang workaround update
-	Modify max HW Rx coalescing size
-	Log SGE doorbell Fifo overflow
-	Use Tx immediate data for offload packets whenever possible
-	RDMA can get internal mem info to workaround HW issues
-	More validity checks on connection ids
-	Stop MAC when a fatal error is detected
-	Log HW serial number
-	Update internal mem operating mode
-	Update engine microcode management, version is now 1.1.0
-	Update FW management, version is now 4.6.0
-	Ignore some HW errors until the HW is initialized
-	Check MSI/MSI-X after it got enabled

Cheers,
Divy
