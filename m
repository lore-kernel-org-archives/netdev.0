From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 055/199] Documentation/isdn/README.audio: Checkpatch cleanup
Date: Sun, 23 May 2010 21:50:19 +0200
Message-ID: <1274644226-23612-5-git-send-email-andrea.gelmini@gelma.net>
References: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Documentation/isdn/README.audio:90: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/isdn/README.audio |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/isdn/README.audio b/Documentation/isdn/README.audio
index 8ebca19..a861f86 100644
--- a/Documentation/isdn/README.audio
+++ b/Documentation/isdn/README.audio
@@ -87,7 +87,7 @@ General behavior and description of data formats/protocol.
       On incoming calls, if the application responds to a RING
       with ATA, depending on the calling service, the emulator
       responds with either CONNECT (data call) or VCON (voice call).
-      
+
       On outgoing voice calls, the emulator responds with VCON
       upon connection setup.
 
-- 
1.7.1.251.gf80a2

