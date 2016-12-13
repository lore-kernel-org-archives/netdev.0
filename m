From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2 0/2] Man page fixes
Date: Tue, 13 Dec 2016 07:33:50 +0200
Message-ID: <1481607232-1342-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45939 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932188AbcLMFeU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 00:34:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The 2 patches are man page related only.
First fixes a typo and second adding missing man page to the Makefile.

Thanks

Roi Dayan (2):
  tc: flower: Fix typo in the flower man page
  tc: tunnel_key: Add tc-tunnel_key man page to Makefile

 man/man8/Makefile    | 1 +
 man/man8/tc-flower.8 | 4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

-- 
2.7.4
