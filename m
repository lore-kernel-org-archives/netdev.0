From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH iproute2] tc: fix typo in tc-tcindex man page
Date: Thu, 14 Sep 2017 17:00:46 +0200
Message-ID: <de07579ec6e41c65103ada6733072874af95773e.1505397960.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45724 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751255AbdINPAu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 14 Sep 2017 11:00:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix mis-typed 'pass_on' keyword.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 man/man8/tc-tcindex.8 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/tc-tcindex.8 b/man/man8/tc-tcindex.8
index 7fcf8254..9a4e5ffc 100644
--- a/man/man8/tc-tcindex.8
+++ b/man/man8/tc-tcindex.8
@@ -11,7 +11,7 @@ tcindex \- traffic control index filter
 .IR MASK " ] [ "
 .B shift
 .IR SHIFT " ] [ "
-.BR pas_on " | " fall_through " ] [ " classid
+.BR pass_on " | " fall_through " ] [ " classid
 .IR CLASSID " ] [ "
 .B action
 .BR ACTION_SPEC " ]"
-- 
2.13.5
