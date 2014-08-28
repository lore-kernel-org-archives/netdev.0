From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 0/4] Remove various orphaned header files
Date: Thu, 28 Aug 2014 13:44:30 +0200
Message-ID: <1409226274-3202-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These four files are not included anywhere, and seem to be accidental
leftovers from past cleanups (see the individual commit messages).

Rasmus Villemoes (4):
  include/linux/cycx_x25.h: Remove unused header
  include/linux/i82593.h: Remove unused header
  include/linux/phonedev.h: Remove unused header
  include/rxrpc/types.h: Remove unused header

 include/linux/cycx_x25.h | 125 --------------------------
 include/linux/i82593.h   | 229 -----------------------------------------------
 include/linux/phonedev.h |  25 ------
 include/rxrpc/types.h    |  41 ---------
 4 files changed, 420 deletions(-)
 delete mode 100644 include/linux/cycx_x25.h
 delete mode 100644 include/linux/i82593.h
 delete mode 100644 include/linux/phonedev.h
 delete mode 100644 include/rxrpc/types.h

-- 
2.0.4
