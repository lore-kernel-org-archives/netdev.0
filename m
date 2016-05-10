From: tcharding <me@tobin.cc>
Subject: [PATCH 0/3] bridge: netfilter: checkpatch fixes
Date: Tue, 10 May 2016 11:26:55 +1000
Message-ID: <1462843618-21914-1-git-send-email-me@tobin.cc>
Cc: Tobin C Harding <me@tobin.cc>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tobin C Harding <me@tobin.cc>

checkpatch produces 32 'checks'. This patch set amends them all.

Patch one is white space only.
Patch two changes data types e.g uint8_t -> u8.
Patch three amends comparison to null.

Tobin C Harding (3):
  bridge: netfilter: checkpatch whitespace fixes
  bridge: netfilter: checkpatch data type fixes
  bridge: netfilter: checkpatch null comparison fixes

 net/bridge/netfilter/ebt_stp.c | 68 +++++++++++++++++++++---------------------
 1 file changed, 34 insertions(+), 34 deletions(-)

-- 
2.8.2

