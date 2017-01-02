From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH net] Documentation/networking: fix typo in mpls-sysctl
Date: Mon,  2 Jan 2017 18:52:24 +0100
Message-ID: <20170102175224.8010-1-alexander@alemayhu.com>
Cc: corbet@lwn.net, Alexander Alemayhu <alexander@alemayhu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:34085 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932719AbdABRw7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 12:52:59 -0500
Received: by mail-lf0-f44.google.com with SMTP id y21so273217036lfa.1
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 09:52:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

s/utliziation/utilization

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 Documentation/networking/mpls-sysctl.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/mpls-sysctl.txt b/Documentation/networking/mpls-sysctl.txt
index 9ed15f86c17c..15d8d16934fd 100644
--- a/Documentation/networking/mpls-sysctl.txt
+++ b/Documentation/networking/mpls-sysctl.txt
@@ -5,8 +5,8 @@ platform_labels - INTEGER
 	possible to configure forwarding for label values equal to or
 	greater than the number of platform labels.
 
-	A dense utliziation of the entries in the platform label table
-	is possible and expected aas the platform labels are locally
+	A dense utilization of the entries in the platform label table
+	is possible and expected as the platform labels are locally
 	allocated.
 
 	If the number of platform label table entries is set to 0 no
-- 
2.11.0
