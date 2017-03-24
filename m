From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH net-next v4 0/2] GTP SGSN-side tunnels
Date: Fri, 24 Mar 2017 14:56:26 +0100
Message-ID: <20170324135628.22955-1-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: pablo@netfilter.org, netdev@vger.kernel.org, laforge@gnumonks.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:50643 "EHLO mail.southpole.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751490AbdCXN5F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 09:57:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from v3:

* Coding style fixup: remove extraneous braces on if-statement
* Ack from Harald

Jonas Bonn (2):
  gtp: rename SGSN netlink attribute
  gtp: support SGSN-side tunnels

 drivers/net/gtp.c            | 62 +++++++++++++++++++++++++++++---------------
 include/uapi/linux/gtp.h     |  3 ++-
 include/uapi/linux/if_link.h |  7 +++++
 3 files changed, 50 insertions(+), 22 deletions(-)

-- 
2.9.3
