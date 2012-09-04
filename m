From: Jesse Gross <jesse@nicira.com>
Subject: [GIT net] Open vSwitch
Date: Tue,  4 Sep 2012 12:08:05 -0700
Message-ID: <1346785688-2910-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:55058 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757489Ab2IDTIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 15:08:15 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr13so9945194pbb.19
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2012 12:08:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few bug fixes intended for net/3.6.

The following changes since commit 0d7614f09c1ebdbaa1599a5aba7593f147bf96ee:

  Linux 3.6-rc1 (2012-08-02 16:38:10 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/jesse/openvswitch.git fixes

for you to fetch changes up to c303aa94cdae483a7577230e61720e126e600a52:

  openvswitch: Fix FLOW_BUFSIZE definition. (2012-09-03 19:06:27 -0700)

----------------------------------------------------------------
Jesse Gross (2):
      openvswitch: Relax set header validation.
      openvswitch: Fix FLOW_BUFSIZE definition.

Joe Stringer (1):
      openvswitch: Fix typo

 net/openvswitch/actions.c  |    2 +-
 net/openvswitch/datapath.c |    6 +++---
 net/openvswitch/flow.h     |    8 +++++---
 3 files changed, 9 insertions(+), 7 deletions(-)
