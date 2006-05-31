From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 0/7][RFC] Ammasso 1100 iWARP Driver
Date: Wed, 31 May 2006 13:27:33 -0500
Message-ID: <20060531182733.3652.54755.stgit@stevo-desktop>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965090AbWEaS3V@vger.kernel.org>
To: rdreier@cisco.com, mshefty@ichips.intel.com
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patchset implements the iWARP provider driver for the Ammasso
1100 RNIC.  It is dependent on the "iWARP Core Support" patch set.  We're
submitting it for review with the goal for inclusion in the 2.6.19 kernel.
This code has gone through several reviews in the openib-general list.
Now we are submitting it for external review by the linux community.

This StGIT patchset is cloned from Roland Dreier's infiniband.git
for-2.6.18 branch.  The patchset consists of 7 patches:

        1 - Kconfig and Makefile
        2 - Low-level device interface and native stack support
        3 - Work request definitions
        4 - Provider interface
        5 - Memory management
        6 - User mode message queue implementation      
        7 - Verbs queue implementation

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
