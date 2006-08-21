From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [take12 4/3] kevent: Comment cleanup.
Date: Mon, 21 Aug 2006 16:37:46 +0400
Message-ID: <20060821123746.GA15416@2ka.mipt.ru>
References: <11561555893621@2ka.mipt.ru> <1156155589287@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47496 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751123AbWHUMl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 08:41:58 -0400
To: lkml <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1156155589287@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove file name from comments.

dda1ae6fe306b485a91ebb5873eeee4bba06aebf
diff --git a/kernel/kevent/kevent.c b/kernel/kevent/kevent.c
index 2872aa2..02ecf30 100644
--- a/kernel/kevent/kevent.c
+++ b/kernel/kevent/kevent.c
@@ -1,6 +1,4 @@
 /*
- * 	kevent.c
- * 
  * 2006 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
  * All rights reserved.
  * 
diff --git a/kernel/kevent/kevent_poll.c b/kernel/kevent/kevent_poll.c
index 75a75d1..0233a4d 100644
--- a/kernel/kevent/kevent_poll.c
+++ b/kernel/kevent/kevent_poll.c
@@ -1,6 +1,4 @@
 /*
- * 	kevent_poll.c
- * 
  * 2006 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
  * All rights reserved.
  * 
diff --git a/kernel/kevent/kevent_timer.c b/kernel/kevent/kevent_timer.c
index 5217cd1..08dfc55 100644
--- a/kernel/kevent/kevent_timer.c
+++ b/kernel/kevent/kevent_timer.c
@@ -1,6 +1,4 @@
 /*
- * 	kevent_timer.c
- * 
  * 2006 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
  * All rights reserved.
  * 

-- 
	Evgeniy Polyakov
