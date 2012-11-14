From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH 0/2] iputils: minor fixes
Date: Wed, 14 Nov 2012 13:57:14 +0100
Message-ID: <1352897836-17603-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422711Ab2KNM5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 07:57:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Synacek (2):
  ping,ping6: Add newline to error message.
  ping: Don't free an unintialized value.

 ping.c        | 8 +++++---
 ping_common.c | 2 +-
 2 files changed, 6 insertions(+), 4 deletions(-)

-- 
1.7.11.7
