From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 3/7] openvswitch: Replace Nicira Networks.
Date: Fri, 20 Jul 2012 15:26:46 -0700
Message-ID: <1342823210-3308-4-git-send-email-jesse@nicira.com>
References: <1342823210-3308-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Raju Subramanian <rsubramanian-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1342823210-3308-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Raju Subramanian <rsubramanian-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Replaced all instances of Nicira Networks(, Inc) to Nicira, Inc.

Signed-off-by: Raju Subramanian <rsubramanian-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/actions.c            |    2 +-
 net/openvswitch/datapath.c           |    2 +-
 net/openvswitch/datapath.h           |    2 +-
 net/openvswitch/dp_notify.c          |    2 +-
 net/openvswitch/flow.c               |    2 +-
 net/openvswitch/flow.h               |    2 +-
 net/openvswitch/vport-internal_dev.c |    2 +-
 net/openvswitch/vport-internal_dev.h |    2 +-
 net/openvswitch/vport-netdev.c       |    2 +-
 net/openvswitch/vport-netdev.h       |    2 +-
 net/openvswitch/vport.c              |    2 +-
 net/openvswitch/vport.h              |    2 +-
 12 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 48badff..f3f96ba 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2012 Nicira Networks.
+ * Copyright (c) 2007-2012 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4813d95..b512cb8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2012 Nicira Networks.
+ * Copyright (c) 2007-2012 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index c73370c..c1105c1 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2012 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index 4673651..36dcee8 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2012 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index c6e1dae..1115dcf 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2011 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 2747dc2..9b75617 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2011 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index b6b1d7d..de509d3 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2012 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/openvswitch/vport-internal_dev.h b/net/openvswitch/vport-internal_dev.h
index 3454447..9a7d30e 100644
--- a/net/openvswitch/vport-internal_dev.h
+++ b/net/openvswitch/vport-internal_dev.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2011 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index c1068ae..54a456d 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2012 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index fd9b008..f7072a2 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2011 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 6c066ba..6140336 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2012 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 1960962..aac680c 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2012 Nicira, Inc.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
-- 
1.7.9.5
