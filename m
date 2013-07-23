From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] net: sctp: trivial: update mailing list address
Date: Tue, 23 Jul 2013 14:51:47 +0200
Message-ID: <1374583908-17152-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932168Ab3GWMvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jul 2013 08:51:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SCTP mailing list address to send patches or questions
to is linux-sctp@vger.kernel.org and not
lksctp-developers@lists.sourceforge.net anymore. Therefore,
update all occurences.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Documentation/networking/sctp.txt | 5 +----
 include/net/sctp/auth.h           | 2 +-
 include/net/sctp/checksum.h       | 2 +-
 include/net/sctp/constants.h      | 2 +-
 include/net/sctp/sctp.h           | 2 +-
 include/net/sctp/sm.h             | 2 +-
 include/net/sctp/structs.h        | 2 +-
 include/net/sctp/tsnmap.h         | 2 +-
 include/net/sctp/ulpevent.h       | 2 +-
 include/net/sctp/ulpqueue.h       | 2 +-
 include/uapi/linux/sctp.h         | 2 +-
 net/sctp/associola.c              | 2 +-
 net/sctp/auth.c                   | 2 +-
 net/sctp/bind_addr.c              | 2 +-
 net/sctp/chunk.c                  | 2 +-
 net/sctp/command.c                | 2 +-
 net/sctp/debug.c                  | 2 +-
 net/sctp/endpointola.c            | 2 +-
 net/sctp/input.c                  | 2 +-
 net/sctp/inqueue.c                | 2 +-
 net/sctp/ipv6.c                   | 2 +-
 net/sctp/objcnt.c                 | 2 +-
 net/sctp/output.c                 | 2 +-
 net/sctp/outqueue.c               | 2 +-
 net/sctp/primitive.c              | 2 +-
 net/sctp/proc.c                   | 2 +-
 net/sctp/protocol.c               | 4 ++--
 net/sctp/sm_make_chunk.c          | 2 +-
 net/sctp/sm_sideeffect.c          | 2 +-
 net/sctp/sm_statefuns.c           | 2 +-
 net/sctp/sm_statetable.c          | 2 +-
 net/sctp/socket.c                 | 2 +-
 net/sctp/ssnmap.c                 | 2 +-
 net/sctp/sysctl.c                 | 2 +-
 net/sctp/transport.c              | 2 +-
 net/sctp/tsnmap.c                 | 2 +-
 net/sctp/ulpevent.c               | 2 +-
 net/sctp/ulpqueue.c               | 2 +-
 38 files changed, 39 insertions(+), 42 deletions(-)

diff --git a/Documentation/networking/sctp.txt b/Documentation/networking/sctp.txt
index 0c790a7..97b810c 100644
--- a/Documentation/networking/sctp.txt
+++ b/Documentation/networking/sctp.txt
@@ -19,7 +19,6 @@ of SCTP that is RFC 2960 compliant and provides an programming interface
 referred to as the  UDP-style API of the Sockets Extensions for SCTP, as 
 proposed in IETF Internet-Drafts.    
 
-
 Caveats:  
 
 -lksctp can be built as statically or as a module.  However, be aware that 
@@ -33,6 +32,4 @@ For more information, please visit the lksctp project website:
    http://www.sf.net/projects/lksctp
 
 Or contact the lksctp developers through the mailing list:
-   <lksctp-developers@lists.sourceforge.net> 
-
-
+   <linux-sctp@vger.kernel.org>
diff --git a/include/net/sctp/auth.h b/include/net/sctp/auth.h
index 49bc957..754c511 100644
--- a/include/net/sctp/auth.h
+++ b/include/net/sctp/auth.h
@@ -22,7 +22,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
index 0cb08e6..78b88aa 100644
--- a/include/net/sctp/checksum.h
+++ b/include/net/sctp/checksum.h
@@ -25,7 +25,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index ca50e075..a1e7aa5 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -25,7 +25,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index d8e37ec..554cf88 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -27,7 +27,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 2a82d13..2aa66dd 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -27,7 +27,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email addresses:
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index e745c92..75c4c16 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -25,7 +25,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email addresses:
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/include/net/sctp/tsnmap.h b/include/net/sctp/tsnmap.h
index 2c5d2b4..c361d6f 100644
--- a/include/net/sctp/tsnmap.h
+++ b/include/net/sctp/tsnmap.h
@@ -28,7 +28,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index ca4693b..34f0d34 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -31,7 +31,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/include/net/sctp/ulpqueue.h b/include/net/sctp/ulpqueue.h
index 00e50ba..add3237 100644
--- a/include/net/sctp/ulpqueue.h
+++ b/include/net/sctp/ulpqueue.h
@@ -30,7 +30,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email addresses:
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 66b466e..ca451e9 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -28,7 +28,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index bce5b79..e425ba0 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -28,7 +28,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index ba1dfc3..3aab967 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -22,7 +22,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index 64977ea..f34ce8b 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -27,7 +27,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 5780565..b50b90c 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -24,7 +24,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/command.c b/net/sctp/command.c
index c004401..f4bebda 100644
--- a/net/sctp/command.c
+++ b/net/sctp/command.c
@@ -25,7 +25,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/debug.c b/net/sctp/debug.c
index f499878..44aa4e7 100644
--- a/net/sctp/debug.c
+++ b/net/sctp/debug.c
@@ -28,7 +28,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 9e3d257..825b754 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -29,7 +29,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 3fa4d85..7993495 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -29,7 +29,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index cb25f04..e70f60a 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -30,7 +30,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 09ffcc9..85d688f 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -27,7 +27,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index fe012c4..aec346c 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -26,7 +26,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/output.c b/net/sctp/output.c
index a46d1eb..5a55c55d 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -26,7 +26,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index ef9e2bb..5131323 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -28,7 +28,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/primitive.c b/net/sctp/primitive.c
index 794bb14..31fa437 100644
--- a/net/sctp/primitive.c
+++ b/net/sctp/primitive.c
@@ -29,7 +29,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 62526c4..aff0cac 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -22,7 +22,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 4a17494d..b52ec25 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -29,7 +29,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
@@ -1547,7 +1547,7 @@ module_exit(sctp_exit);
  */
 MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-132");
 MODULE_ALIAS("net-pf-" __stringify(PF_INET6) "-proto-132");
-MODULE_AUTHOR("Linux Kernel SCTP developers <lksctp-developers@lists.sourceforge.net>");
+MODULE_AUTHOR("Linux Kernel SCTP developers <linux-sctp@vger.kernel.org>");
 MODULE_DESCRIPTION("Support for the SCTP protocol (RFC2960)");
 module_param_named(no_checksums, sctp_checksum_disable, bool, 0644);
 MODULE_PARM_DESC(no_checksums, "Disable checksums computing and verification");
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 362ae6e..780a2d4 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -29,7 +29,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 9da6885..f1f3aac 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -28,7 +28,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index f6b7109..93271f0 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -28,7 +28,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index 84d98d8..64ea5fd 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -28,7 +28,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index c6670d2..0245712 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -34,7 +34,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/ssnmap.c b/net/sctp/ssnmap.c
index da86035..72b5939 100644
--- a/net/sctp/ssnmap.c
+++ b/net/sctp/ssnmap.c
@@ -24,7 +24,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 9a5c4c9..1906747 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -25,7 +25,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index bdbbc3f..9602c52 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -30,7 +30,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
index b460195..0eff866 100644
--- a/net/sctp/tsnmap.c
+++ b/net/sctp/tsnmap.c
@@ -27,7 +27,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 44a45db..c07624f 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -28,7 +28,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 04e3d47..2cdb301 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -27,7 +27,7 @@
  *
  * Please send any bug reports or fixes you make to the
  * email address(es):
- *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *    lksctp developers <linux-sctp@vger.kernel.org>
  *
  * Or submit a bug report through the following website:
  *    http://www.sf.net/projects/lksctp
-- 
1.7.11.7
