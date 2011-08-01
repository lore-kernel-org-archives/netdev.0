From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 2/2] doc: Update the email address for Paul Moore in various
 source files
Date: Mon, 01 Aug 2011 17:10:33 -0400
Message-ID: <20110801211033.11940.92986.stgit@localhost6.localdomain6>
References: <20110801210642.11940.49764.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: paul@paul-moore.com
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20110801210642.11940.49764.stgit@localhost6.localdomain6>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My @hp.com will no longer be valid starting August 5, 2011 so an update is
necessary.  My new email address is employer independent so we don't have
to worry about doing this again any time soon.

Signed-off-by: Paul Moore <paul.moore@hp.com>
Signed-off-by: Paul Moore <paul@paul-moore.com>
---
 include/net/cipso_ipv4.h            |    2 +-
 include/net/netlabel.h              |    2 +-
 net/netlabel/Makefile               |    2 --
 net/netlabel/netlabel_addrlist.c    |    2 +-
 net/netlabel/netlabel_addrlist.h    |    2 +-
 net/netlabel/netlabel_cipso_v4.c    |    2 +-
 net/netlabel/netlabel_cipso_v4.h    |    2 +-
 net/netlabel/netlabel_domainhash.c  |    2 +-
 net/netlabel/netlabel_domainhash.h  |    2 +-
 net/netlabel/netlabel_kapi.c        |    2 +-
 net/netlabel/netlabel_mgmt.c        |    2 +-
 net/netlabel/netlabel_mgmt.h        |    2 +-
 net/netlabel/netlabel_unlabeled.c   |    2 +-
 net/netlabel/netlabel_unlabeled.h   |    2 +-
 net/netlabel/netlabel_user.c        |    2 +-
 net/netlabel/netlabel_user.h        |    2 +-
 security/selinux/hooks.c            |    2 +-
 security/selinux/include/netif.h    |    2 +-
 security/selinux/include/netlabel.h |    2 +-
 security/selinux/include/netnode.h  |    2 +-
 security/selinux/include/netport.h  |    2 +-
 security/selinux/netif.c            |    2 +-
 security/selinux/netlabel.c         |    2 +-
 security/selinux/netnode.c          |    2 +-
 security/selinux/netport.c          |    2 +-
 security/selinux/selinuxfs.c        |    2 +-
 security/selinux/ss/ebitmap.c       |    2 +-
 security/selinux/ss/mls.c           |    2 +-
 security/selinux/ss/mls.h           |    2 +-
 security/selinux/ss/policydb.c      |    2 +-
 security/selinux/ss/services.c      |    2 +-
 security/smack/smack_lsm.c          |    2 +-
 32 files changed, 31 insertions(+), 33 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index 3b93874..9808877 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -8,7 +8,7 @@
  * have chosen to adopt the protocol and over the years it has become a
  * de-facto standard for labeled networking.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/include/net/netlabel.h b/include/net/netlabel.h
index f21a16e..f674409 100644
--- a/include/net/netlabel.h
+++ b/include/net/netlabel.h
@@ -4,7 +4,7 @@
  * The NetLabel system manages static and dynamic label mappings for network
  * protocols such as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/Makefile b/net/netlabel/Makefile
index ea750e9..d2732fc 100644
--- a/net/netlabel/Makefile
+++ b/net/netlabel/Makefile
@@ -1,8 +1,6 @@
 #
 # Makefile for the NetLabel subsystem.
 #
-# Feb 9, 2006, Paul Moore <paul.moore@hp.com>
-#
 
 # base objects
 obj-y	:= netlabel_user.o netlabel_kapi.o
diff --git a/net/netlabel/netlabel_addrlist.c b/net/netlabel/netlabel_addrlist.c
index c051913..96b749d 100644
--- a/net/netlabel/netlabel_addrlist.c
+++ b/net/netlabel/netlabel_addrlist.c
@@ -6,7 +6,7 @@
  * system manages static and dynamic label mappings for network protocols such
  * as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_addrlist.h b/net/netlabel/netlabel_addrlist.h
index 2b9644e..fdbc1d2 100644
--- a/net/netlabel/netlabel_addrlist.h
+++ b/net/netlabel/netlabel_addrlist.h
@@ -6,7 +6,7 @@
  * system manages static and dynamic label mappings for network protocols such
  * as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
index dd53a36..6bf8783 100644
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -5,7 +5,7 @@
  * NetLabel system manages static and dynamic label mappings for network
  * protocols such as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_cipso_v4.h b/net/netlabel/netlabel_cipso_v4.h
index af7f335..d24d774 100644
--- a/net/netlabel/netlabel_cipso_v4.h
+++ b/net/netlabel/netlabel_cipso_v4.h
@@ -5,7 +5,7 @@
  * NetLabel system manages static and dynamic label mappings for network
  * protocols such as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 2aa975e..7d8083c 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -6,7 +6,7 @@
  * system manages static and dynamic label mappings for network protocols such
  * as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_domainhash.h b/net/netlabel/netlabel_domainhash.h
index 0261dda..bfcc0f7 100644
--- a/net/netlabel/netlabel_domainhash.h
+++ b/net/netlabel/netlabel_domainhash.h
@@ -6,7 +6,7 @@
  * system manages static and dynamic label mappings for network protocols such
  * as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index b528dd9..58107d0 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -5,7 +5,7 @@
  * system manages static and dynamic label mappings for network protocols such
  * as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_mgmt.c b/net/netlabel/netlabel_mgmt.c
index dff8a08..bfa5558 100644
--- a/net/netlabel/netlabel_mgmt.c
+++ b/net/netlabel/netlabel_mgmt.c
@@ -5,7 +5,7 @@
  * NetLabel system manages static and dynamic label mappings for network
  * protocols such as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_mgmt.h b/net/netlabel/netlabel_mgmt.h
index 8db37f4..5a9f31c 100644
--- a/net/netlabel/netlabel_mgmt.h
+++ b/net/netlabel/netlabel_mgmt.h
@@ -5,7 +5,7 @@
  * NetLabel system manages static and dynamic label mappings for network
  * protocols such as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index f1ecf84..e6e8236 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -5,7 +5,7 @@
  * NetLabel system.  The NetLabel system manages static and dynamic label
  * mappings for network protocols such as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_unlabeled.h b/net/netlabel/netlabel_unlabeled.h
index 0bc8dc3..700af49 100644
--- a/net/netlabel/netlabel_unlabeled.h
+++ b/net/netlabel/netlabel_unlabeled.h
@@ -5,7 +5,7 @@
  * NetLabel system.  The NetLabel system manages static and dynamic label
  * mappings for network protocols such as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_user.c b/net/netlabel/netlabel_user.c
index a3fd75a..9fae63f 100644
--- a/net/netlabel/netlabel_user.c
+++ b/net/netlabel/netlabel_user.c
@@ -5,7 +5,7 @@
  * NetLabel system manages static and dynamic label mappings for network
  * protocols such as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/net/netlabel/netlabel_user.h b/net/netlabel/netlabel_user.h
index f4fc4c9..8196978 100644
--- a/net/netlabel/netlabel_user.h
+++ b/net/netlabel/netlabel_user.h
@@ -5,7 +5,7 @@
  * NetLabel system manages static and dynamic label mappings for network
  * protocols such as CIPSO and RIPSO.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index a38316b..266a229 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -14,7 +14,7 @@
  *  Copyright (C) 2004-2005 Trusted Computer Solutions, Inc.
  *			    <dgoeddel@trustedcs.com>
  *  Copyright (C) 2006, 2007, 2009 Hewlett-Packard Development Company, L.P.
- *	Paul Moore <paul.moore@hp.com>
+ *	Paul Moore <paul@paul-moore.com>
  *  Copyright (C) 2007 Hitachi Software Engineering Co., Ltd.
  *		       Yuichi Nakamura <ynakam@hitachisoft.jp>
  *
diff --git a/security/selinux/include/netif.h b/security/selinux/include/netif.h
index ce23edd..43d5072 100644
--- a/security/selinux/include/netif.h
+++ b/security/selinux/include/netif.h
@@ -8,7 +8,7 @@
  *
  * Copyright (C) 2003 Red Hat, Inc., James Morris <jmorris@redhat.com>
  * Copyright (C) 2007 Hewlett-Packard Development Company, L.P.
- *                    Paul Moore, <paul.moore@hp.com>
+ *                    Paul Moore <paul@paul-moore.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2,
diff --git a/security/selinux/include/netlabel.h b/security/selinux/include/netlabel.h
index cf2f628..8c59b8f 100644
--- a/security/selinux/include/netlabel.h
+++ b/security/selinux/include/netlabel.h
@@ -1,7 +1,7 @@
 /*
  * SELinux interface to the NetLabel subsystem
  *
- * Author : Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/security/selinux/include/netnode.h b/security/selinux/include/netnode.h
index 1b94450..df7a5ed 100644
--- a/security/selinux/include/netnode.h
+++ b/security/selinux/include/netnode.h
@@ -6,7 +6,7 @@
  * needed to reduce the lookup overhead since most of these queries happen on
  * a per-packet basis.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/security/selinux/include/netport.h b/security/selinux/include/netport.h
index 8991752..4d965b8 100644
--- a/security/selinux/include/netport.h
+++ b/security/selinux/include/netport.h
@@ -5,7 +5,7 @@
  * mapping is maintained as part of the normal policy but a fast cache is
  * needed to reduce the lookup overhead.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/security/selinux/netif.c b/security/selinux/netif.c
index 58cc481..326f22c 100644
--- a/security/selinux/netif.c
+++ b/security/selinux/netif.c
@@ -8,7 +8,7 @@
  *
  * Copyright (C) 2003 Red Hat, Inc., James Morris <jmorris@redhat.com>
  * Copyright (C) 2007 Hewlett-Packard Development Company, L.P.
- *		      Paul Moore <paul.moore@hp.com>
+ *		      Paul Moore <paul@paul-moore.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2,
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index c3bf3ed..da4b8b2 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -4,7 +4,7 @@
  * This file provides the necessary glue to tie NetLabel into the SELinux
  * subsystem.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  */
 
diff --git a/security/selinux/netnode.c b/security/selinux/netnode.c
index 8b691a8..3bf46ab 100644
--- a/security/selinux/netnode.c
+++ b/security/selinux/netnode.c
@@ -6,7 +6,7 @@
  * needed to reduce the lookup overhead since most of these queries happen on
  * a per-packet basis.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  * This code is heavily based on the "netif" concept originally developed by
  * James Morris <jmorris@redhat.com>
diff --git a/security/selinux/netport.c b/security/selinux/netport.c
index ae76e29..0b62bd1 100644
--- a/security/selinux/netport.c
+++ b/security/selinux/netport.c
@@ -5,7 +5,7 @@
  * mapping is maintained as part of the normal policy but a fast cache is
  * needed to reduce the lookup overhead.
  *
- * Author: Paul Moore <paul.moore@hp.com>
+ * Author: Paul Moore <paul@paul-moore.com>
  *
  * This code is heavily based on the "netif" concept originally developed by
  * James Morris <jmorris@redhat.com>
diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
index de7900e..55d92cb 100644
--- a/security/selinux/selinuxfs.c
+++ b/security/selinux/selinuxfs.c
@@ -2,7 +2,7 @@
  *
  *	Added conditional policy language extensions
  *
- *  Updated: Hewlett-Packard <paul.moore@hp.com>
+ *  Updated: Hewlett-Packard <paul@paul-moore.com>
  *
  *	Added support for the policy capability bitmap
  *
diff --git a/security/selinux/ss/ebitmap.c b/security/selinux/ss/ebitmap.c
index d42951f..30f119b 100644
--- a/security/selinux/ss/ebitmap.c
+++ b/security/selinux/ss/ebitmap.c
@@ -4,7 +4,7 @@
  * Author : Stephen Smalley, <sds@epoch.ncsc.mil>
  */
 /*
- * Updated: Hewlett-Packard <paul.moore@hp.com>
+ * Updated: Hewlett-Packard <paul@paul-moore.com>
  *
  *      Added support to import/export the NetLabel category bitmap
  *
diff --git a/security/selinux/ss/mls.c b/security/selinux/ss/mls.c
index e961742..fbf9c58 100644
--- a/security/selinux/ss/mls.c
+++ b/security/selinux/ss/mls.c
@@ -11,7 +11,7 @@
  * Copyright (C) 2004-2006 Trusted Computer Solutions, Inc.
  */
 /*
- * Updated: Hewlett-Packard <paul.moore@hp.com>
+ * Updated: Hewlett-Packard <paul@paul-moore.com>
  *
  *      Added support to import/export the MLS label from NetLabel
  *
diff --git a/security/selinux/ss/mls.h b/security/selinux/ss/mls.h
index 037bf9d..e4369e3 100644
--- a/security/selinux/ss/mls.h
+++ b/security/selinux/ss/mls.h
@@ -11,7 +11,7 @@
  * Copyright (C) 2004-2006 Trusted Computer Solutions, Inc.
  */
 /*
- * Updated: Hewlett-Packard <paul.moore@hp.com>
+ * Updated: Hewlett-Packard <paul@paul-moore.com>
  *
  *	Added support to import/export the MLS label from NetLabel
  *
diff --git a/security/selinux/ss/policydb.c b/security/selinux/ss/policydb.c
index d246aca..2381d0d 100644
--- a/security/selinux/ss/policydb.c
+++ b/security/selinux/ss/policydb.c
@@ -13,7 +13,7 @@
  *
  *	Added conditional policy language extensions
  *
- * Updated: Hewlett-Packard <paul.moore@hp.com>
+ * Updated: Hewlett-Packard <paul@paul-moore.com>
  *
  *      Added support for the policy capability bitmap
  *
diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
index 973e00e..f6917bc 100644
--- a/security/selinux/ss/services.c
+++ b/security/selinux/ss/services.c
@@ -13,7 +13,7 @@
  *
  *	Added conditional policy language extensions
  *
- * Updated: Hewlett-Packard <paul.moore@hp.com>
+ * Updated: Hewlett-Packard <paul@paul-moore.com>
  *
  *      Added support for NetLabel
  *      Added support for the policy capability bitmap
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index f375eb2..b9c5e14 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -9,7 +9,7 @@
  *
  *  Copyright (C) 2007 Casey Schaufler <casey@schaufler-ca.com>
  *  Copyright (C) 2009 Hewlett-Packard Development Company, L.P.
- *                Paul Moore <paul.moore@hp.com>
+ *                Paul Moore <paul@paul-moore.com>
  *  Copyright (C) 2010 Nokia Corporation
  *
  *	This program is free software; you can redistribute it and/or modify

