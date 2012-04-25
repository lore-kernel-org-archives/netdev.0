From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: fixed a coding style issue in net/core/sock.c
Date: Wed, 25 Apr 2012 19:38:52 +0530
Message-ID: <20120425140852.GA3653@debian.Jeff>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ahiliation@yahoo.co.in
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hello .

I have fixed a coding style issue relating
to spaces in net/core/sock.c


>From e05ee2cbdea9a888695f01358fa2ea53ddb2a49b Mon Sep 17 00:00:00 2001
From: Jeffrin Jose <ahiliation@yahoo.co.in>
Date: Wed, 25 Apr 2012 19:17:29 +0530
Subject: [PATCH 8/8] net:Fixed a coding style issue related to spaces.

Fixed a coding style issue relating to spaces
in net/core/sock.c
Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/core/sock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 02f8dfe..65cdc19 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2556,7 +2556,7 @@ static char proto_method_implemented(const void *method)
 }
 static long sock_prot_memory_allocated(struct proto *proto)
 {
-	return proto->memory_allocated != NULL ? proto_memory_allocated(proto): -1L;
+	return proto->memory_allocated != NULL ? proto_memory_allocated(proto) : -1L;
 }
 
 static char *sock_prot_memory_pressure(struct proto *proto)
-- 
1.7.9



/Jeffrin.


-- 
software engineer
Bohr Lab
department of computer science
Rajagiri school of engineering and technology.
