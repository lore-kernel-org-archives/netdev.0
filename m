From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 0/2] minor net kernel-doc fixes
Date: Wed, 12 Jul 2017 09:29:05 -0700
Message-ID: <20170712162907.18465-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a couple of small errors in kernel-doc for networking

Stephen Hemminger (2):
  socket: add documentation for missing elements
  datagram: fix kernel-doc comments

 include/net/sock.h  | 3 +++
 net/core/datagram.c | 6 +++---
 2 files changed, 6 insertions(+), 3 deletions(-)

-- 
2.11.0

