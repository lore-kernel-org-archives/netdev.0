From: SZ Lin <sz.lin@moxa.com>
Subject: [PATCH 0/6] net: moxa: Fix style issues
Date: Sat, 29 Jul 2017 18:42:33 +0800
Message-ID: <20170729104239.14999-1-sz.lin@moxa.com>
Cc: jarod@redhat.com, jonas.jensen@gmail.com, edumazet@google.com,
        bhumirks@gmail.com, tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, SZ Lin <sz.lin@moxa.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set fixs the WARNINGs found by the checkpatch.pl tool

SZ Lin (6):
  net: moxa: Remove braces from single-line body
  net: moxa: Prefer 'unsigned int' to bare use of 'unsigned'
  net: moxa: Fix comparison to NULL could be written with !
  net: moxa: Remove extra space after a cast
  net: moxa: Fix for typo in comment to function
    moxart_mac_setup_desc_ring()
  net: moxa: Add spaces preferred around that '{+,-}'

 drivers/net/ethernet/moxa/moxart_ether.c | 15 +++++++--------
 drivers/net/ethernet/moxa/moxart_ether.h |  8 ++++----
 2 files changed, 11 insertions(+), 12 deletions(-)

-- 
2.13.3
