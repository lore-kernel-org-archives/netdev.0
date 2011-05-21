From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] Add and use WARN_RATELIMIT
Date: Sat, 21 May 2011 10:48:38 -0700
Message-ID: <cover.1305999731.git.joe@perches.com>
References: <1305666832.1722.62.camel@Joe-Laptop>
Cc: "David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>, linux-arch@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305666832.1722.62.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Generic mechanism to ratelimit WARN uses.

Joe Perches (2):
  bug.h: Add WARN_RATELIMIT
  net: filter: Use WARN_RATELIMIT

 include/asm-generic/bug.h |   16 ++++++++++++++++
 net/core/filter.c         |    4 +++-
 2 files changed, 19 insertions(+), 1 deletions(-)

-- 
1.7.5.rc3.dirty
