From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 0/4] Whitespace checkpatch fixes
Date: Thu,  9 Feb 2017 17:56:03 +1100
Message-ID: <1486623367-28861-1-git-send-email-me@tobin.cc>
Cc: Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        stephen hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Tobin C. Harding" <me@tobin.cc>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:49139 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751751AbdBIHOG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 02:14:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes various whitespace checkpatch errors and warnings.

Tobin C. Harding (4):
  net: Fix checkpatch WARNING: please, no space before tabs
  net: Fix checkpatch whitespace errors
  net: Fix checkpatch block comments warnings
  net: Fix checkpatch, Missing a blank line after declarations

 net/core/dev.c | 259 ++++++++++++++++++++++++++++++---------------------------
 1 file changed, 137 insertions(+), 122 deletions(-)

-- 
2.7.4



"David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING [GENERAL],commit_signer:72/82=88%)
Eric Dumazet <edumazet@google.com> (commit_signer:23/82=28%,authored:19/82=23%,added_lines:150/1100=14%,removed_lines:104/791=13%)
Alexander Duyck <alexander.h.duyck@intel.com> (commit_signer:14/82=17%,authored:11/82=13%,added_lines:259/1100=24%,removed_lines:66/791=8%)
David Ahern <dsa@cumulusnetworks.com> (commit_signer:9/82=11%,authored:7/82=9%,added_lines:219/1100=20%,removed_lines:230/791=29%)
Jesper Dangaard Brouer <brouer@redhat.com> (commit_signer:6/82=7%)
"Tobin C. Harding" <me@tobin.cc> (added_lines:137/1100=12%,removed_lines:122/791=15%)
Jiri Pirko <jiri@mellanox.com> (added_lines:90/1100=8%)
stephen hemminger <stephen@networkplumber.org> (removed_lines:136/791=17%)
netdev@vger.kernel.org (open list:NETWORKING [GENERAL])
linux-kernel@vger.kernel.org (open list)
 
