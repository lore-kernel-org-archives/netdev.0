From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/5] drivers/net/mac8390 cleanups
Date: Mon,  4 Jan 2010 13:52:58 -0800
Message-ID: <cover.1262630406.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: Paul Gortmaker <p_gortmaker@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1486 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752794Ab0ADVxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 16:53:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Collection of trivial cleanups to mac8390
Uncompiled (no cross-compiler)
No hardware to verify

Joe Perches (5):
  drivers/net/mac8390.c: Indent case labels
  drivers/net/mac8390.c: Remove useless memcpy casting
  drivers/net/mac8390.c: Convert printk(KERN_<level> to pr_<level>(
  drivers/net/mac8390.c: Checkpatch cleanups
  drivers/net/mac8390.c: Add mac8390_init function

 drivers/net/mac8390.c |  632 +++++++++++++++++++++++++------------------------
 1 files changed, 322 insertions(+), 310 deletions(-)

