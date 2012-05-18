From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/5] cirrus: cs89x0: Neatening
Date: Fri, 18 May 2012 15:56:26 -0700
Message-ID: <cover.1337381533.git.joe@perches.com>
Cc: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yeah, some might consider it gratuitous.
I think it's cleaner now though.

Joe Perches (5):
  cirrus: cs89x0: Code style neatening
  cirrus: cs89x0: Convert printks to pr_<level>
  cirrus: cs89x0: Code neatening
  cirrus: cs89x0: Neaten debugging and logging
  cirrus: cs89x0: Remove function prototypes and reorder declarations

 drivers/net/ethernet/cirrus/cs89x0.c | 2408 +++++++++++++++++-----------------
 1 files changed, 1185 insertions(+), 1223 deletions(-)

-- 
1.7.8.111.gad25c.dirty
