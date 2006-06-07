From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH v2 0/2][RFC] iWARP Core Support
Date: Wed, 07 Jun 2006 15:06:00 -0500
Message-ID: <20060607200600.9003.56328.stgit@stevo-desktop>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	openib-general@openib.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-227-247-179.sw.biz.rr.com ([24.227.247.179]:18603 "EHLO
	linux.local") by vger.kernel.org with ESMTP id S1751184AbWFGUGB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 16:06:01 -0400
To: rdreier@cisco.com, mshefty@ichips.intel.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patchset defines the modifications to the Linux infiniband subsystem
to support iWARP devices.  We're submitting it for review now with the
goal for inclusion in the 2.6.19 kernel.  This code has gone through
several reviews in the openib-general list.  Now we are submitting it
for external review by the linux community.

This StGIT patchset is cloned from Roland Dreier's infiniband.git
for-2.6.18 branch.  The patchset consists of 2 patches:

        1 - New iWARP CM implementation.  
        2 - Core changes to support iWARP.

I believe I've addressed all the round 1 review comments.  Details of
the changes are tracked in each patch comment.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
