From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] docbook: networking: fix file paths for uapi headers
Date: Sun, 14 Oct 2012 18:50:05 -0700
Message-ID: <507B6BCD.3040708@xenotime.net>
References: <CA+55aFyt0KFNp5Binu-c3-XzF=MG+23EDOk1R6t4qqgW58ksAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFyt0KFNp5Binu-c3-XzF=MG+23EDOk1R6t4qqgW58ksAw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Update file paths in Documentation/DocBook/networking.tmpl for uapi headers.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 Documentation/DocBook/networking.tmpl |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- lnx-37-rc1.orig/Documentation/DocBook/networking.tmpl
+++ lnx-37-rc1/Documentation/DocBook/networking.tmpl
@@ -56,7 +56,7 @@
 !Enet/core/filter.c
      </sect1>
      <sect1><title>Generic Network Statistics</title>
-!Iinclude/linux/gen_stats.h
+!Iinclude/uapi/linux/gen_stats.h
 !Enet/core/gen_stats.c
 !Enet/core/gen_estimator.c
      </sect1>
@@ -80,7 +80,7 @@
 !Enet/wimax/op-rfkill.c
 !Enet/wimax/stack.c
 !Iinclude/net/wimax.h
-!Iinclude/linux/wimax.h
+!Iinclude/uapi/linux/wimax.h
      </sect1>
   </chapter>
 
