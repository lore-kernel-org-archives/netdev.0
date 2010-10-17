From: Bandan Das <bandan.das@stratus.com>
Subject: [PATCH 0/2] bonding: checkpatch.pl cleanups in bond_3ad.c
Date: Sun, 17 Oct 2010 02:19:57 -0400
Message-ID: <1287296399-25142-1-git-send-email-bandan.das@stratus.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, joe@perches.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Bandan Das <bandan.das@stratus.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just some cleanups based on errors/warnings reported by checkpatch.pl.
There are still a ton of lines greater than 80 chars and I tried to fix 
a few that I came across.

Bandan Das (2):
  bonding: cleanup : add space around operators
  bonding: cleanup: remove braces from single block statements

 drivers/net/bonding/bond_3ad.c |  274 ++++++++++++++++++++--------------------
 1 files changed, 139 insertions(+), 135 deletions(-)

-- 
Bandan
