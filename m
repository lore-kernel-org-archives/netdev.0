From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2 V2 0/2] Man pages fixes
Date: Tue, 13 Dec 2016 14:39:00 +0200
Message-ID: <1481632742-18020-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38417 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932580AbcLMMku (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 07:40:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The 2 patches are man page related only.
First fixes a typo and second adding missing man page to the Makefile.

Thanks,
Roi

v2:
- style fix in flower man page

Roi Dayan (2):
  tc: flower: Fix typo and style in flower man page
  tc: tunnel_key: Add tc-tunnel_key man page to Makefile

 man/man8/Makefile    |  1 +
 man/man8/tc-flower.8 | 10 +++++-----
 2 files changed, 6 insertions(+), 5 deletions(-)

-- 
2.7.4
