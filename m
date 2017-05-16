From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/2] net: dsa: Sort various lists
Date: Tue, 16 May 2017 22:40:06 +0200
Message-ID: <1494967208-11550-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60839 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751529AbdEPUlO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 16:41:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we gain more DSA drivers and tagging protocols, the lists are
getting a bit unruly. Do some sorting.

Andrew Lunn (2):
  net: dsa: Sort DSA tagging protocol drivers
  drivers: net: DSA: Sort drivers

 drivers/net/dsa/Kconfig  | 40 ++++++++++++++++++++--------------------
 drivers/net/dsa/Makefile |  6 +++---
 include/net/dsa.h        |  8 ++++----
 net/dsa/Kconfig          |  8 ++++----
 net/dsa/Makefile         |  6 +++---
 net/dsa/dsa.c            | 18 +++++++++---------
 net/dsa/dsa_priv.h       | 18 +++++++++---------
 7 files changed, 52 insertions(+), 52 deletions(-)

-- 
2.11.0
