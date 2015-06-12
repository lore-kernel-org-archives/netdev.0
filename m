From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] Doc: networking: Fix URL for wiki.wireshark.org in udplite.txt
Date: Sat, 13 Jun 2015 00:23:21 +0900
Message-ID: <1434122601-2123-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: corbet@lwn.net, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix URL (http to https) for wiki.wireshark.org.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/networking/udplite.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/udplite.txt b/Documentation/networking/udplite.txt
index d727a38..53a7268 100644
--- a/Documentation/networking/udplite.txt
+++ b/Documentation/networking/udplite.txt
@@ -20,7 +20,7 @@
 	files/UDP-Lite-HOWTO.txt
 
    o The Wireshark UDP-Lite WiKi (with capture files):
-       http://wiki.wireshark.org/Lightweight_User_Datagram_Protocol
+       https://wiki.wireshark.org/Lightweight_User_Datagram_Protocol
 
    o The Protocol Spec, RFC 3828, http://www.ietf.org/rfc/rfc3828.txt
 
-- 
2.4.3.413.ga5fe668
