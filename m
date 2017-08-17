From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 0/2] Covscan: Shell script fixes
Date: Thu, 17 Aug 2017 19:09:30 +0200
Message-ID: <20170817170932.24900-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53807 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753428AbdHQRNE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:13:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series collects patches from v1 which deal with programming
mistakes in shell scripts.

No changes to the actual patches, just splitting into smaller series.

Phil Sutter (2):
  examples: Some shell fixes to cbq.init
  ifcfg: Quote left-hand side of [ ] expression

 examples/cbq.init-v0.7.3 | 24 ++++++++++++------------
 ip/ifcfg                 |  2 +-
 2 files changed, 13 insertions(+), 13 deletions(-)

-- 
2.13.1
