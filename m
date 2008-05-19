From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/: remove CVS keywords
Date: Tue, 20 May 2008 00:58:55 +0300
Message-ID: <20080519215855.GU17716@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:42172 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755898AbYESWBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 18:01:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes CVS keywords that weren't updated for a long time 
from comments.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/linux/if_bridge.h          |    2 --
 include/linux/if_ppp.h             |    2 --
 include/linux/if_tun.h             |    2 --
 include/linux/ip6_tunnel.h         |    4 ----
 include/linux/ppp-comp.h           |    2 --
 include/linux/ppp_defs.h           |    2 --
 include/linux/sunrpc/auth_gss.h    |    2 --
 include/linux/sunrpc/gss_api.h     |    2 --
 include/linux/sunrpc/svcauth_gss.h |    3 ---
 include/net/inetpeer.h             |    2 --
 include/net/ip6_tunnel.h           |    4 ----
 include/net/ipconfig.h             |    2 --
 include/net/ipv6.h                 |    2 --
 include/net/snmp.h                 |    2 --
 net/bluetooth/bnep/bnep.h          |    4 ----
 net/bluetooth/bnep/core.c          |    4 ----
 net/bluetooth/bnep/netdev.c        |    4 ----
 net/bluetooth/bnep/sock.c          |    4 ----
 net/bluetooth/rfcomm/core.c        |    2 --
 net/bluetooth/rfcomm/sock.c        |    2 --
 net/bluetooth/rfcomm/tty.c         |    2 --
 net/bridge/br.c                    |    2 --
 net/bridge/br_device.c             |    2 --
 net/bridge/br_fdb.c                |    2 --
 net/bridge/br_forward.c            |    2 --
 net/bridge/br_if.c                 |    2 --
 net/bridge/br_input.c              |    2 --
 net/bridge/br_ioctl.c              |    2 --
 net/bridge/br_notify.c             |    2 --
 net/bridge/br_private.h            |    2 --
 net/bridge/br_private_stp.h        |    2 --
 net/bridge/br_stp.c                |    2 --
 net/bridge/br_stp_bpdu.c           |    2 --
 net/bridge/br_stp_if.c             |    2 --
 net/bridge/br_stp_timer.c          |    2 --
 net/core/skbuff.c                  |    2 --
 net/core/sock.c                    |    2 --
 net/ipv4/af_inet.c                 |    2 --
 net/ipv4/arp.c                     |    2 --
 net/ipv4/devinet.c                 |    2 --
 net/ipv4/fib_frontend.c            |    2 --
 net/ipv4/fib_hash.c                |    2 --
 net/ipv4/fib_semantics.c           |    2 --
 net/ipv4/fib_trie.c                |    2 --
 net/ipv4/icmp.c                    |    2 --
 net/ipv4/igmp.c                    |    2 --
 net/ipv4/inet_diag.c               |    2 --
 net/ipv4/inetpeer.c                |    2 --
 net/ipv4/ip_forward.c              |    2 --
 net/ipv4/ip_fragment.c             |    2 --
 net/ipv4/ip_input.c                |    2 --
 net/ipv4/ip_options.c              |    2 --
 net/ipv4/ip_output.c               |    2 --
 net/ipv4/ip_sockglue.c             |    2 --
 net/ipv4/ipconfig.c                |    2 --
 net/ipv4/ipip.c                    |    2 --
 net/ipv4/ipmr.c                    |    2 --
 net/ipv4/ipvs/ip_vs_app.c          |    2 --
 net/ipv4/ipvs/ip_vs_conn.c         |    2 --
 net/ipv4/ipvs/ip_vs_core.c         |    2 --
 net/ipv4/ipvs/ip_vs_ctl.c          |    2 --
 net/ipv4/ipvs/ip_vs_dh.c           |    2 --
 net/ipv4/ipvs/ip_vs_est.c          |    2 --
 net/ipv4/ipvs/ip_vs_ftp.c          |    2 --
 net/ipv4/ipvs/ip_vs_lblc.c         |    2 --
 net/ipv4/ipvs/ip_vs_lblcr.c        |    2 --
 net/ipv4/ipvs/ip_vs_lc.c           |    2 --
 net/ipv4/ipvs/ip_vs_nq.c           |    2 --
 net/ipv4/ipvs/ip_vs_proto.c        |    2 --
 net/ipv4/ipvs/ip_vs_proto_ah.c     |    2 --
 net/ipv4/ipvs/ip_vs_proto_esp.c    |    2 --
 net/ipv4/ipvs/ip_vs_proto_tcp.c    |    2 --
 net/ipv4/ipvs/ip_vs_proto_udp.c    |    2 --
 net/ipv4/ipvs/ip_vs_rr.c           |    2 --
 net/ipv4/ipvs/ip_vs_sched.c        |    2 --
 net/ipv4/ipvs/ip_vs_sed.c          |    2 --
 net/ipv4/ipvs/ip_vs_sh.c           |    2 --
 net/ipv4/ipvs/ip_vs_sync.c         |    2 --
 net/ipv4/ipvs/ip_vs_wlc.c          |    2 --
 net/ipv4/ipvs/ip_vs_wrr.c          |    2 --
 net/ipv4/ipvs/ip_vs_xmit.c         |    2 --
 net/ipv4/proc.c                    |    2 --
 net/ipv4/protocol.c                |    2 --
 net/ipv4/raw.c                     |    2 --
 net/ipv4/route.c                   |    2 --
 net/ipv4/syncookies.c              |    2 --
 net/ipv4/sysctl_net_ipv4.c         |    2 --
 net/ipv4/tcp.c                     |    2 --
 net/ipv4/tcp_diag.c                |    2 --
 net/ipv4/tcp_input.c               |    2 --
 net/ipv4/tcp_ipv4.c                |    2 --
 net/ipv4/tcp_minisocks.c           |    2 --
 net/ipv4/tcp_output.c              |    2 --
 net/ipv4/tcp_timer.c               |    2 --
 net/ipv4/udp.c                     |    2 --
 net/ipv4/udplite.c                 |    2 --
 net/ipv6/addrconf.c                |    2 --
 net/ipv6/af_inet6.c                |    2 --
 net/ipv6/datagram.c                |    2 --
 net/ipv6/exthdrs.c                 |    2 --
 net/ipv6/icmp.c                    |    2 --
 net/ipv6/ip6_fib.c                 |    2 --
 net/ipv6/ip6_input.c               |    2 --
 net/ipv6/ip6_output.c              |    2 --
 net/ipv6/ip6_tunnel.c              |    2 --
 net/ipv6/ipv6_sockglue.c           |    2 --
 net/ipv6/mcast.c                   |    2 --
 net/ipv6/proc.c                    |    2 --
 net/ipv6/protocol.c                |    2 --
 net/ipv6/raw.c                     |    2 --
 net/ipv6/reassembly.c              |    2 --
 net/ipv6/route.c                   |    2 --
 net/ipv6/sit.c                     |    2 --
 net/ipv6/tcp_ipv6.c                |    2 --
 net/ipv6/udp.c                     |    2 --
 net/ipv6/udplite.c                 |    2 --
 net/packet/af_packet.c             |    2 --
 net/sched/sch_htb.c                |    2 --
 net/sunrpc/auth_gss/auth_gss.c     |    2 --
 net/sysctl_net.c                   |    1 -
 net/unix/af_unix.c                 |    2 --
 121 files changed, 254 deletions(-)

1726569594be41a6655513737bb57812b068ff78 diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 950e13d..6badb3e 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -4,8 +4,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: if_bridge.h,v 1.1 2000/02/18 16:47:01 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/include/linux/if_ppp.h b/include/linux/if_ppp.h
index 0f2f70d..c3b1f85 100644
--- a/include/linux/if_ppp.h
+++ b/include/linux/if_ppp.h
@@ -1,5 +1,3 @@
-/*	$Id: if_ppp.h,v 1.21 2000/03/27 06:03:36 paulus Exp $	*/
-
 /*
  * if_ppp.h - Point-to-Point Protocol definitions.
  *
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 8c71fe2..18f31b6 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -11,8 +11,6 @@
  *  but WITHOUT ANY WARRANTY; without even the implied warranty of
  *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  *  GNU General Public License for more details.
- *
- *  $Id: if_tun.h,v 1.2 2001/06/01 18:39:47 davem Exp $
  */
 
 #ifndef __IF_TUN_H
diff --git a/include/linux/ip6_tunnel.h b/include/linux/ip6_tunnel.h
index af3f4a7..1e7cc4a 100644
--- a/include/linux/ip6_tunnel.h
+++ b/include/linux/ip6_tunnel.h
@@ -1,7 +1,3 @@
-/*
- * $Id$
- */
-
 #ifndef _IP6_TUNNEL_H
 #define _IP6_TUNNEL_H
 
diff --git a/include/linux/ppp-comp.h b/include/linux/ppp-comp.h
index e86a7a5..b8d4ddd 100644
--- a/include/linux/ppp-comp.h
+++ b/include/linux/ppp-comp.h
@@ -23,8 +23,6 @@
  * ON AN "AS IS" BASIS, AND THE AUSTRALIAN NATIONAL UNIVERSITY HAS NO
  * OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS,
  * OR MODIFICATIONS.
- *
- * $Id: ppp-comp.h,v 1.6 1997/11/27 06:04:44 paulus Exp $
  */
 
 /*
diff --git a/include/linux/ppp_defs.h b/include/linux/ppp_defs.h
index c6b13ff..6e8adc7 100644
--- a/include/linux/ppp_defs.h
+++ b/include/linux/ppp_defs.h
@@ -1,5 +1,3 @@
-/*	$Id: ppp_defs.h,v 1.2 1994/09/21 01:31:06 paulus Exp $	*/
-
 /*
  * ppp_defs.h - PPP definitions.
  *
diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index fec6899..d48d4e6 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -7,8 +7,6 @@
  * Andy Adamson <andros@umich.edu>
  * Bruce Fields <bfields@umich.edu>
  * Copyright (c) 2000 The Regents of the University of Michigan
- *
- * $Id$
  */
 
 #ifndef _LINUX_SUNRPC_AUTH_GSS_H
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 459c5fc..03f3333 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -7,8 +7,6 @@
  * Andy Adamson <andros@umich.edu>
  * Bruce Fields <bfields@umich.edu>
  * Copyright (c) 2000 The Regents of the University of Michigan
- *
- * $Id$
  */
 
 #ifndef _LINUX_SUNRPC_GSS_API_H
diff --git a/include/linux/sunrpc/svcauth_gss.h b/include/linux/sunrpc/svcauth_gss.h
index 417a1de..c9165d9 100644
--- a/include/linux/sunrpc/svcauth_gss.h
+++ b/include/linux/sunrpc/svcauth_gss.h
@@ -3,9 +3,6 @@
  *
  * Bruce Fields <bfields@umich.edu>
  * Copyright (c) 2002 The Regents of the Unviersity of Michigan
- *
- * $Id$
- *
  */
 
 #ifndef _LINUX_SUNRPC_SVCAUTH_GSS_H
diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index ad8404b..15e1f8f 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -1,8 +1,6 @@
 /*
  *		INETPEER - A storage for permanent information about peers
  *
- *  Version:	$Id: inetpeer.h,v 1.2 2002/01/12 07:54:56 davem Exp $
- *
  *  Authors:	Andrey V. Savochkin <saw@msu.ru>
  */
 
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 6512d85..17b595c 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -1,7 +1,3 @@
-/*
- * $Id$
- */
-
 #ifndef _NET_IP6_TUNNEL_H
 #define _NET_IP6_TUNNEL_H
 
diff --git a/include/net/ipconfig.h b/include/net/ipconfig.h
index 3924d7d..c74cc1b 100644
--- a/include/net/ipconfig.h
+++ b/include/net/ipconfig.h
@@ -1,6 +1,4 @@
 /*
- *  $Id: ipconfig.h,v 1.4 2001/04/30 04:51:46 davem Exp $
- *
  *  Copyright (C) 1997 Martin Mares
  *
  *  Automatic IP Layer Configuration
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e0a612b..7f7db8d 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -4,8 +4,6 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *
- *	$Id: ipv6.h,v 1.1 2002/05/20 15:13:07 jgrimm Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
diff --git a/include/net/snmp.h b/include/net/snmp.h
index ce2f485..57c9362 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -14,8 +14,6 @@
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
  *
- *		$Id: snmp.h,v 1.19 2001/06/14 13:40:46 davem Exp $
- *
  */
  
 #ifndef _SNMP_H
diff --git a/net/bluetooth/bnep/bnep.h b/net/bluetooth/bnep/bnep.h
index e69244d..b69bf4e 100644
--- a/net/bluetooth/bnep/bnep.h
+++ b/net/bluetooth/bnep/bnep.h
@@ -16,10 +16,6 @@
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 */
 
-/*
- * $Id: bnep.h,v 1.5 2002/08/04 21:23:58 maxk Exp $
- */
-
 #ifndef _BNEP_H
 #define _BNEP_H
 
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index f85d946..1d98a1b 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -25,10 +25,6 @@
    SOFTWARE IS DISCLAIMED.
 */
 
-/*
- * $Id: core.c,v 1.20 2002/08/04 21:23:58 maxk Exp $
- */
-
 #include <linux/module.h>
 
 #include <linux/kernel.h>
diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
index 95e3837..d9fa0ab 100644
--- a/net/bluetooth/bnep/netdev.c
+++ b/net/bluetooth/bnep/netdev.c
@@ -25,10 +25,6 @@
    SOFTWARE IS DISCLAIMED.
 */
 
-/*
- * $Id: netdev.c,v 1.8 2002/08/04 21:23:58 maxk Exp $
- */
-
 #include <linux/module.h>
 
 #include <linux/socket.h>
diff --git a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
index 201e5b1..8ffb57f 100644
--- a/net/bluetooth/bnep/sock.c
+++ b/net/bluetooth/bnep/sock.c
@@ -24,10 +24,6 @@
    SOFTWARE IS DISCLAIMED.
 */
 
-/*
- * $Id: sock.c,v 1.4 2002/08/04 21:23:58 maxk Exp $
- */
-
 #include <linux/module.h>
 
 #include <linux/types.h>
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index eb62558..0fabf09 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -23,8 +23,6 @@
 
 /*
  * Bluetooth RFCOMM core.
- *
- * $Id: core.c,v 1.42 2002/10/01 23:26:25 maxk Exp $
  */
 
 #include <linux/module.h>
diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
index 5083adc..c905448 100644
--- a/net/bluetooth/rfcomm/sock.c
+++ b/net/bluetooth/rfcomm/sock.c
@@ -23,8 +23,6 @@
 
 /*
  * RFCOMM sockets.
- *
- * $Id: sock.c,v 1.24 2002/10/03 01:00:34 maxk Exp $
  */
 
 #include <linux/module.h>
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index c3f749a..09eafbb 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -23,8 +23,6 @@
 
 /*
  * RFCOMM TTY.
- *
- * $Id: tty.c,v 1.24 2002/10/03 01:54:38 holtmann Exp $
  */
 
 #include <linux/module.h>
diff --git a/net/bridge/br.c b/net/bridge/br.c
index 8f3c58e..cede010 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br.c,v 1.47 2001/12/24 00:56:41 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index bf77873..1b0d1ef 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_device.c,v 1.6 2001/12/24 00:59:55 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 72c5976..4de74cd 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_fdb.c,v 1.6 2002/01/17 00:57:07 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index bdd7c35..39217b1 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_forward.c,v 1.4 2001/08/14 22:05:57 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c2397f5..143c954 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_if.c,v 1.7 2001/12/24 00:59:55 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 255c00f..cadb990 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_input.c,v 1.10 2001/12/24 04:50:20 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index 0655a5f..eeee218 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_ioctl.c,v 1.4 2000/11/08 05:16:40 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 00644a5..88d8ec7 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_notify.c,v 1.2 2000/02/21 15:51:34 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c11b554..4a16a9f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -4,8 +4,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_private.h,v 1.7 2001/12/24 00:59:55 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_private_stp.h b/net/bridge/br_private_stp.h
index e29f01a..8b650f7 100644
--- a/net/bridge/br_private_stp.h
+++ b/net/bridge/br_private_stp.h
@@ -4,8 +4,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_private_stp.h,v 1.3 2001/02/05 06:03:47 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index e38034a..284d1b2 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_stp.c,v 1.4 2000/06/19 10:13:35 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index ddeb6e5..9dc2de6 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_stp_bpdu.c,v 1.3 2001/11/10 02:35:25 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 1a430ec..1a4e5c3 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_stp_if.c,v 1.4 2001/04/14 21:14:39 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 77f5255..772a140 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Lennert Buytenhek		<buytenh@gnu.org>
  *
- *	$Id: br_stp_timer.c,v 1.3 2000/05/05 02:17:17 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5c459f2..f89093e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4,8 +4,6 @@
  *	Authors:	Alan Cox <iiitac@pyr.swan.ac.uk>
  *			Florian La Roche <rzsfl@rz.uni-sb.de>
  *
- *	Version:	$Id: skbuff.c,v 1.90 2001/11/07 05:56:19 davem Exp $
- *
  *	Fixes:
  *		Alan Cox	:	Fixed the worst of the load
  *					balancer bugs.
diff --git a/net/core/sock.c b/net/core/sock.c
index 88094cb..3879bf6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -7,8 +7,6 @@
  *		handler for protocols to use and generic option handler.
  *
  *
- * Version:	$Id: sock.c,v 1.117 2002/02/01 22:01:03 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Florian La Roche, <flla@stud.uni-sb.de>
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 24eca23..42bd24b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -5,8 +5,6 @@
  *
  *		PF_INET protocol family socket handler.
  *
- * Version:	$Id: af_inet.c,v 1.137 2002/02/01 22:01:03 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Florian La Roche, <flla@stud.uni-sb.de>
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 418862f..ea583a2 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1,7 +1,5 @@
 /* linux/net/ipv4/arp.c
  *
- * Version:	$Id: arp.c,v 1.99 2001/08/30 22:55:42 davem Exp $
- *
  * Copyright (C) 1994 by Florian  La Roche
  *
  * This module implements the Address Resolution Protocol ARP (RFC 826),
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 6848e47..6f5a391 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1,8 +1,6 @@
 /*
  *	NET3	IP device support routines.
  *
- *	Version: $Id: devinet.c,v 1.44 2001/10/31 21:55:54 davem Exp $
- *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
  *		as published by the Free Software Foundation; either version
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 0f1557a..1014021 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -5,8 +5,6 @@
  *
  *		IPv4 Forwarding Information Base: FIB frontend.
  *
- * Version:	$Id: fib_frontend.c,v 1.26 2001/10/31 21:55:54 davem Exp $
- *
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
  *
  *		This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 2e2fc33..eeec4bf 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -5,8 +5,6 @@
  *
  *		IPv4 FIB: lookup engine and maintenance routines.
  *
- * Version:	$Id: fib_hash.c,v 1.13 2001/10/31 21:55:54 davem Exp $
- *
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
  *
  *		This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3b83c34..9335eba 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -5,8 +5,6 @@
  *
  *		IPv4 Forwarding Information Base: semantics.
  *
- * Version:	$Id: fib_semantics.c,v 1.19 2002/01/12 07:54:56 davem Exp $
- *
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
  *
  *		This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 4b02d14..394db9c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -22,8 +22,6 @@
  * IP-address lookup using LC-tries. Stefan Nilsson and Gunnar Karlsson
  * IEEE Journal on Selected Areas in Communications, 17(6):1083-1092, June 1999
  *
- * Version:	$Id: fib_trie.c,v 1.3 2005/06/08 14:20:01 robert Exp $
- *
  *
  * Code from fib_hash has been reused which includes the following header:
  *
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 8739735..aa7cf46 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -3,8 +3,6 @@
  *
  *		Alan Cox, <alan@redhat.com>
  *
- *	Version: $Id: icmp.c,v 1.85 2002/02/01 22:01:03 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
  *	as published by the Free Software Foundation; either version
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 2769dc4..68e84a9 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -8,8 +8,6 @@
  *	the older version didn't come out right using gcc 2.5.8, the newer one
  *	seems to fall out with gcc 2.6.2.
  *
- *	Version: $Id: igmp.c,v 1.47 2002/02/01 22:01:03 davem Exp $
- *
  *	Authors:
  *		Alan Cox <Alan.Cox@linux.org>
  *
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index da97695..c10036e 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -1,8 +1,6 @@
 /*
  * inet_diag.c	Module for monitoring INET transport protocols sockets.
  *
- * Version:	$Id: inet_diag.c,v 1.3 2002/02/01 22:01:04 davem Exp $
- *
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
  *
  *	This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index af99519..a456cee 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -3,8 +3,6 @@
  *
  *  This source is covered by the GNU GPL, the same as all kernel sources.
  *
- *  Version:	$Id: inetpeer.c,v 1.7 2001/09/20 21:22:50 davem Exp $
- *
  *  Authors:	Andrey V. Savochkin <saw@msu.ru>
  */
 
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 4813c39..37d36a3 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -5,8 +5,6 @@
  *
  *		The IP forwarding functionality.
  *
- * Version:	$Id: ip_forward.c,v 1.48 2000/12/13 18:31:48 davem Exp $
- *
  * Authors:	see ip.c
  *
  * Fixes:
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index cd6ce6a..ed24ae9 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -5,8 +5,6 @@
  *
  *		The IP fragmentation functionality.
  *
- * Version:	$Id: ip_fragment.c,v 1.59 2002/01/12 07:54:56 davem Exp $
- *
  * Authors:	Fred N. van Kempen <waltje@uWalt.NL.Mugnet.ORG>
  *		Alan Cox <Alan.Cox@linux.org>
  *
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index ff77a4a..7c26428 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -5,8 +5,6 @@
  *
  *		The Internet Protocol (IP) module.
  *
- * Version:	$Id: ip_input.c,v 1.55 2002/01/12 07:39:45 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Donald Becker, <becker@super.org>
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 33126ad..be3f18a 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -5,8 +5,6 @@
  *
  *		The options processing module for ip.c
  *
- * Version:	$Id: ip_options.c,v 1.21 2001/09/01 00:31:50 davem Exp $
- *
  * Authors:	A.N.Kuznetsov
  *
  */
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e527628..f1278ee 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -5,8 +5,6 @@
  *
  *		The Internet Protocol (IP) output module.
  *
- * Version:	$Id: ip_output.c,v 1.100 2002/02/01 22:01:03 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Donald Becker, <becker@super.org>
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index e0514e8..105d92a 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -5,8 +5,6 @@
  *
  *		The IP to API glue.
  *
- * Version:	$Id: ip_sockglue.c,v 1.62 2002/02/01 22:01:04 davem Exp $
- *
  * Authors:	see ip.c
  *
  * Fixes:
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index ed45037..b88aa9a 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1,6 +1,4 @@
 /*
- *  $Id: ipconfig.c,v 1.46 2002/02/01 22:01:04 davem Exp $
- *
  *  Automatic Configuration of IP -- use DHCP, BOOTP, RARP, or
  *  user-supplied information to configure own IP address and routes.
  *
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 149111f..804f032 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -1,8 +1,6 @@
 /*
  *	Linux NET3:	IP/IP protocol decoder.
  *
- *	Version: $Id: ipip.c,v 1.50 2001/10/02 02:22:36 davem Exp $
- *
  *	Authors:
  *		Sam Lantinga (slouken@cs.ucdavis.edu)  02/01/95
  *
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 11700a4..ecaff3e 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -9,8 +9,6 @@
  *	as published by the Free Software Foundation; either version
  *	2 of the License, or (at your option) any later version.
  *
- *	Version: $Id: ipmr.c,v 1.65 2001/10/31 21:55:54 davem Exp $
- *
  *	Fixes:
  *	Michael Chastain	:	Incorrect size of copying.
  *	Alan Cox		:	Added the cache manager code
diff --git a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
index 535abe0..1f1897a 100644
--- a/net/ipv4/ipvs/ip_vs_app.c
+++ b/net/ipv4/ipvs/ip_vs_app.c
@@ -1,8 +1,6 @@
 /*
  * ip_vs_app.c: Application module support for IPVS
  *
- * Version:     $Id: ip_vs_app.c,v 1.17 2003/03/22 06:31:21 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *
  *              This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
index 65f1ba1..f8bdae4 100644
--- a/net/ipv4/ipvs/ip_vs_conn.c
+++ b/net/ipv4/ipvs/ip_vs_conn.c
@@ -5,8 +5,6 @@
  *              high-performance and highly available server based on a
  *              cluster of servers.
  *
- * Version:     $Id: ip_vs_conn.c,v 1.31 2003/04/18 09:03:16 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *              Peter Kese <peter.kese@ijs.si>
  *              Julian Anastasov <ja@ssi.bg>
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 963981a..bcf6276 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -5,8 +5,6 @@
  *              high-performance and highly available server based on a
  *              cluster of servers.
  *
- * Version:     $Id: ip_vs_core.c,v 1.34 2003/05/10 03:05:23 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *              Peter Kese <peter.kese@ijs.si>
  *              Julian Anastasov <ja@ssi.bg>
diff --git a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
index 94c5767..9a5ace0 100644
--- a/net/ipv4/ipvs/ip_vs_ctl.c
+++ b/net/ipv4/ipvs/ip_vs_ctl.c
@@ -5,8 +5,6 @@
  *              high-performance and highly available server based on a
  *              cluster of servers.
  *
- * Version:     $Id: ip_vs_ctl.c,v 1.36 2003/06/08 09:31:19 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *              Peter Kese <peter.kese@ijs.si>
  *              Julian Anastasov <ja@ssi.bg>
diff --git a/net/ipv4/ipvs/ip_vs_dh.c b/net/ipv4/ipvs/ip_vs_dh.c
index dcf5d46..8afc150 100644
--- a/net/ipv4/ipvs/ip_vs_dh.c
+++ b/net/ipv4/ipvs/ip_vs_dh.c
@@ -1,8 +1,6 @@
 /*
  * IPVS:        Destination Hashing scheduling module
  *
- * Version:     $Id: ip_vs_dh.c,v 1.5 2002/09/15 08:14:08 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@gnuchina.org>
  *
  *              Inspired by the consistent hashing scheduler patch from
diff --git a/net/ipv4/ipvs/ip_vs_est.c b/net/ipv4/ipvs/ip_vs_est.c
index dfa0d71..bc04eed 100644
--- a/net/ipv4/ipvs/ip_vs_est.c
+++ b/net/ipv4/ipvs/ip_vs_est.c
@@ -1,8 +1,6 @@
 /*
  * ip_vs_est.c: simple rate estimator for IPVS
  *
- * Version:     $Id: ip_vs_est.c,v 1.4 2002/11/30 01:50:35 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *
  *              This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/ipvs/ip_vs_ftp.c b/net/ipv4/ipvs/ip_vs_ftp.c
index 59aa166..c1c758e 100644
--- a/net/ipv4/ipvs/ip_vs_ftp.c
+++ b/net/ipv4/ipvs/ip_vs_ftp.c
@@ -1,8 +1,6 @@
 /*
  * ip_vs_ftp.c: IPVS ftp application module
  *
- * Version:	$Id: ip_vs_ftp.c,v 1.13 2002/09/15 08:14:08 wensong Exp $
- *
  * Authors:	Wensong Zhang <wensong@linuxvirtualserver.org>
  *
  * Changes:
diff --git a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
index 3888642..0efa3db 100644
--- a/net/ipv4/ipvs/ip_vs_lblc.c
+++ b/net/ipv4/ipvs/ip_vs_lblc.c
@@ -1,8 +1,6 @@
 /*
  * IPVS:        Locality-Based Least-Connection scheduling module
  *
- * Version:     $Id: ip_vs_lblc.c,v 1.10 2002/09/15 08:14:08 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@gnuchina.org>
  *
  *              This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
index daa260e..8e3bbeb 100644
--- a/net/ipv4/ipvs/ip_vs_lblcr.c
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c
@@ -1,8 +1,6 @@
 /*
  * IPVS:        Locality-Based Least-Connection with Replication scheduler
  *
- * Version:     $Id: ip_vs_lblcr.c,v 1.11 2002/09/15 08:14:08 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@gnuchina.org>
  *
  *              This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
index d88fef9..ac9f08e 100644
--- a/net/ipv4/ipvs/ip_vs_lc.c
+++ b/net/ipv4/ipvs/ip_vs_lc.c
@@ -1,8 +1,6 @@
 /*
  * IPVS:        Least-Connection Scheduling module
  *
- * Version:     $Id: ip_vs_lc.c,v 1.10 2003/04/18 09:03:16 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *
  *              This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
index bc2a9e5..a46bf25 100644
--- a/net/ipv4/ipvs/ip_vs_nq.c
+++ b/net/ipv4/ipvs/ip_vs_nq.c
@@ -1,8 +1,6 @@
 /*
  * IPVS:        Never Queue scheduling module
  *
- * Version:     $Id: ip_vs_nq.c,v 1.2 2003/06/08 09:31:19 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *
  *              This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index 4b1c16c..876714f 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -1,8 +1,6 @@
 /*
  * ip_vs_proto.c: transport protocol load balancing support for IPVS
  *
- * Version:     $Id: ip_vs_proto.c,v 1.2 2003/04/18 09:03:16 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *              Julian Anastasov <ja@ssi.bg>
  *
diff --git a/net/ipv4/ipvs/ip_vs_proto_ah.c b/net/ipv4/ipvs/ip_vs_proto_ah.c
index 4bf835e..73e0ea8 100644
--- a/net/ipv4/ipvs/ip_vs_proto_ah.c
+++ b/net/ipv4/ipvs/ip_vs_proto_ah.c
@@ -1,8 +1,6 @@
 /*
  * ip_vs_proto_ah.c:	AH IPSec load balancing support for IPVS
  *
- * Version:     $Id: ip_vs_proto_ah.c,v 1.1 2003/07/04 15:04:37 wensong Exp $
- *
  * Authors:	Julian Anastasov <ja@ssi.bg>, February 2002
  *		Wensong Zhang <wensong@linuxvirtualserver.org>
  *
diff --git a/net/ipv4/ipvs/ip_vs_proto_esp.c b/net/ipv4/ipvs/ip_vs_proto_esp.c
index db6a6b7..21d70c8 100644
--- a/net/ipv4/ipvs/ip_vs_proto_esp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_esp.c
@@ -1,8 +1,6 @@
 /*
  * ip_vs_proto_esp.c:	ESP IPSec load balancing support for IPVS
  *
- * Version:     $Id: ip_vs_proto_esp.c,v 1.1 2003/07/04 15:04:37 wensong Exp $
- *
  * Authors:	Julian Anastasov <ja@ssi.bg>, February 2002
  *		Wensong Zhang <wensong@linuxvirtualserver.org>
  *
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index b83dc14..d0ea467 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -1,8 +1,6 @@
 /*
  * ip_vs_proto_tcp.c:	TCP load balancing support for IPVS
  *
- * Version:     $Id: ip_vs_proto_tcp.c,v 1.3 2002/11/30 01:50:35 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *              Julian Anastasov <ja@ssi.bg>
  *
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 75771cb..c6be5d5 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -1,8 +1,6 @@
 /*
  * ip_vs_proto_udp.c:	UDP load balancing support for IPVS
  *
- * Version:     $Id: ip_vs_proto_udp.c,v 1.3 2002/11/30 01:50:35 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *              Julian Anastasov <ja@ssi.bg>
  *
diff --git a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
index 433f8a9..c8db12d 100644
--- a/net/ipv4/ipvs/ip_vs_rr.c
+++ b/net/ipv4/ipvs/ip_vs_rr.c
@@ -1,8 +1,6 @@
 /*
  * IPVS:        Round-Robin Scheduling module
  *
- * Version:     $Id: ip_vs_rr.c,v 1.9 2002/09/15 08:14:08 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *              Peter Kese <peter.kese@ijs.si>
  *
diff --git a/net/ipv4/ipvs/ip_vs_sched.c b/net/ipv4/ipvs/ip_vs_sched.c
index 121a32b..b647673 100644
--- a/net/ipv4/ipvs/ip_vs_sched.c
+++ b/net/ipv4/ipvs/ip_vs_sched.c
@@ -5,8 +5,6 @@
  *              high-performance and highly available server based on a
  *              cluster of servers.
  *
- * Version:     $Id: ip_vs_sched.c,v 1.13 2003/05/10 03:05:23 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *              Peter Kese <peter.kese@ijs.si>
  *
diff --git a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
index dd7c128..2a7d313 100644
--- a/net/ipv4/ipvs/ip_vs_sed.c
+++ b/net/ipv4/ipvs/ip_vs_sed.c
@@ -1,8 +1,6 @@
 /*
  * IPVS:        Shortest Expected Delay scheduling module
  *
- * Version:     $Id: ip_vs_sed.c,v 1.1 2003/05/10 03:06:08 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *
  *              This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/ipvs/ip_vs_sh.c b/net/ipv4/ipvs/ip_vs_sh.c
index 1b25b00..b8fdfac 100644
--- a/net/ipv4/ipvs/ip_vs_sh.c
+++ b/net/ipv4/ipvs/ip_vs_sh.c
@@ -1,8 +1,6 @@
 /*
  * IPVS:        Source Hashing scheduling module
  *
- * Version:     $Id: ip_vs_sh.c,v 1.5 2002/09/15 08:14:08 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@gnuchina.org>
  *
  *              This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
index eff54ef..2d4a86f 100644
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -5,8 +5,6 @@
  *              high-performance and highly available server based on a
  *              cluster of servers.
  *
- * Version:     $Id: ip_vs_sync.c,v 1.13 2003/06/08 09:31:19 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *
  * ip_vs_sync:  sync connection info from master load balancer to backups
diff --git a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
index 8a9d913..772c3cb 100644
--- a/net/ipv4/ipvs/ip_vs_wlc.c
+++ b/net/ipv4/ipvs/ip_vs_wlc.c
@@ -1,8 +1,6 @@
 /*
  * IPVS:        Weighted Least-Connection Scheduling module
  *
- * Version:     $Id: ip_vs_wlc.c,v 1.13 2003/04/18 09:03:16 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *              Peter Kese <peter.kese@ijs.si>
  *
diff --git a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
index 85c680a..1d6932d 100644
--- a/net/ipv4/ipvs/ip_vs_wrr.c
+++ b/net/ipv4/ipvs/ip_vs_wrr.c
@@ -1,8 +1,6 @@
 /*
  * IPVS:        Weighted Round-Robin Scheduling module
  *
- * Version:     $Id: ip_vs_wrr.c,v 1.12 2002/09/15 08:14:08 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *
  *              This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index f63006c..9892d4a 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -1,8 +1,6 @@
 /*
  * ip_vs_xmit.c: various packet transmitters for IPVS
  *
- * Version:     $Id: ip_vs_xmit.c,v 1.2 2002/11/30 01:50:35 wensong Exp $
- *
  * Authors:     Wensong Zhang <wensong@linuxvirtualserver.org>
  *              Julian Anastasov <ja@ssi.bg>
  *
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 552169b..eb5cee2 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -7,8 +7,6 @@
  *		PROC file system.  It is mainly used for debugging and
  *		statistics.
  *
- * Version:	$Id: proc.c,v 1.45 2001/05/16 16:45:35 davem Exp $
- *
  * Authors:	Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Gerald J. Heim, <heim@peanuts.informatik.uni-tuebingen.de>
  *		Fred Baumgarten, <dc6iq@insu1.etec.uni-karlsruhe.de>
diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index 971ab93..ea50da0 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -5,8 +5,6 @@
  *
  *		INET protocol dispatch tables.
  *
- * Version:	$Id: protocol.c,v 1.14 2001/05/18 02:25:49 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index fead049..f8427c7 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -5,8 +5,6 @@
  *
  *		RAW - implementation of IP "raw" sockets.
  *
- * Version:	$Id: raw.c,v 1.64 2002/02/01 22:01:04 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 92f90ae..5e83193 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -5,8 +5,6 @@
  *
  *		ROUTE - implementation of the IP router.
  *
- * Version:	$Id: route.c,v 1.103 2002/01/12 07:44:09 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Alan Cox, <gw4pts@gw4pts.ampr.org>
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 73ba989..6317d3c 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -8,8 +8,6 @@
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
  *      2 of the License, or (at your option) any later version.
- *
- *  $Id: syncookies.c,v 1.18 2002/02/01 22:01:04 davem Exp $
  */
 
 #include <linux/tcp.h>
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index c437f80..9016070 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -1,8 +1,6 @@
 /*
  * sysctl_net_ipv4.c: sysctl interface to net IPV4 subsystem.
  *
- * $Id: sysctl_net_ipv4.c,v 1.50 2001/10/20 00:00:11 davem Exp $
- *
  * Begun April 1, 1996, Mike Shaver.
  * Added /proc/sys/net/ipv4 directory entry (empty =) ). [MS]
  */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index f886531..85cba70 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -5,8 +5,6 @@
  *
  *		Implementation of the Transmission Control Protocol(TCP).
  *
- * Version:	$Id: tcp.c,v 1.216 2002/02/01 22:01:04 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Mark Evans, <evansmp@uhura.aston.ac.uk>
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 2fbcc7d..838d491 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -1,8 +1,6 @@
 /*
  * tcp_diag.c	Module for monitoring TCP transport protocols sockets.
  *
- * Version:	$Id: tcp_diag.c,v 1.3 2002/02/01 22:01:04 davem Exp $
- *
  * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
  *
  *	This program is free software; you can redistribute it and/or
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b54d9d3..b606d90 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5,8 +5,6 @@
  *
  *		Implementation of the Transmission Control Protocol(TCP).
  *
- * Version:	$Id: tcp_input.c,v 1.243 2002/02/01 22:01:04 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Mark Evans, <evansmp@uhura.aston.ac.uk>
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cd601a8..f2926ae 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -5,8 +5,6 @@
  *
  *		Implementation of the Transmission Control Protocol(TCP).
  *
- * Version:	$Id: tcp_ipv4.c,v 1.240 2002/02/01 22:01:04 davem Exp $
- *
  *		IPv4 specific functions
  *
  *
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 019c8c1..1276cab 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -5,8 +5,6 @@
  *
  *		Implementation of the Transmission Control Protocol(TCP).
  *
- * Version:	$Id: tcp_minisocks.c,v 1.15 2002/02/01 22:01:04 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Mark Evans, <evansmp@uhura.aston.ac.uk>
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index debf235..88f37f3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -5,8 +5,6 @@
  *
  *		Implementation of the Transmission Control Protocol(TCP).
  *
- * Version:	$Id: tcp_output.c,v 1.146 2002/02/01 22:01:04 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Mark Evans, <evansmp@uhura.aston.ac.uk>
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 4de68cf..e77e7ae 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -5,8 +5,6 @@
  *
  *		Implementation of the Transmission Control Protocol(TCP).
  *
- * Version:	$Id: tcp_timer.c,v 1.88 2002/02/01 22:01:04 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Mark Evans, <evansmp@uhura.aston.ac.uk>
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index db1cb7c..129a3b1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -5,8 +5,6 @@
  *
  *		The User Datagram Protocol (UDP).
  *
- * Version:	$Id: udp.c,v 1.102 2002/02/01 22:01:04 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Arnt Gulbrandsen, <agulbra@nvg.unit.no>
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 72ce26b..4ad16b6 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -1,8 +1,6 @@
 /*
  *  UDPLITE     An implementation of the UDP-Lite protocol (RFC 3828).
  *
- *  Version:    $Id: udplite.c,v 1.25 2006/10/19 07:22:36 gerrit Exp $
- *
  *  Authors:    Gerrit Renker       <gerrit@erg.abdn.ac.uk>
  *
  *  Changes:
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e591e09..0c29e54 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -6,8 +6,6 @@
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *	Alexey Kuznetsov	<kuznet@ms2.inr.ac.ru>
  *
- *	$Id: addrconf.c,v 1.69 2001/10/31 21:55:54 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3c6aafb..9f71385 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -7,8 +7,6 @@
  *
  *	Adapted from linux/net/ipv4/af_inet.c
  *
- *	$Id: af_inet6.c,v 1.66 2002/02/01 22:01:04 davem Exp $
- *
  * 	Fixes:
  *	piggy, Karl Knutson	:	Socket protocol table
  * 	Hideaki YOSHIFUJI	:	sin6_scope_id support
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 94fa6ae..4fe7584 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *
- *	$Id: datagram.c,v 1.24 2002/02/01 22:01:04 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 3cd1c99..602ea82 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -7,8 +7,6 @@
  *	Andi Kleen		<ak@muc.de>
  *	Alexey Kuznetsov	<kuznet@ms2.inr.ac.ru>
  *
- *	$Id: exthdrs.c,v 1.13 2001/06/19 15:58:56 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index d42dd16..399d41f 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *
- *	$Id: icmp.c,v 1.38 2002/02/08 03:57:19 davem Exp $
- *
  *	Based on net/ipv4/icmp.c
  *
  *	RFC 1885
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 1ee4fa1..4de2b9e 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *
- *	$Id: ip6_fib.c,v 1.25 2001/10/31 21:55:55 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 4e5c861..f77a601 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -6,8 +6,6 @@
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *	Ian P. Morris		<I.P.Morris@soton.ac.uk>
  *
- *	$Id: ip6_input.c,v 1.19 2000/12/13 18:31:50 davem Exp $
- *
  *	Based in linux/net/ipv4/ip_input.c
  *
  *	This program is free software; you can redistribute it and/or
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 48cdce9..40a2813 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *
- *	$Id: ip6_output.c,v 1.34 2002/02/01 22:01:04 davem Exp $
- *
  *	Based on linux/net/ipv4/ip_output.c
  *
  *	This program is free software; you can redistribute it and/or
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 2bda3ba..8e4ad2e 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -6,8 +6,6 @@
  *	Ville Nuorvala		<vnuorval@tcs.hut.fi>
  *	Yasuyuki Kozakai	<kozakai@linux-ipv6.org>
  *
- *	$Id$
- *
  *      Based on:
  *      linux/net/ipv6/sit.c and linux/net/ipv4/ipip.c
  *
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 56d55fe..b2fc074 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -7,8 +7,6 @@
  *
  *	Based on linux/net/ipv4/ip_sockglue.c
  *
- *	$Id: ipv6_sockglue.c,v 1.41 2002/02/01 22:01:04 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index fd632dd..fbb2d12 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *
- *	$Id: mcast.c,v 1.40 2002/02/08 03:57:19 davem Exp $
- *
  *	Based on linux/ipv4/igmp.c and linux/ipv4/ip_sockglue.c
  *
  *	This program is free software; you can redistribute it and/or
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index df0736a..cbc7e51 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -7,8 +7,6 @@
  *		PROC file system.  This is very similar to the IPv4 version,
  *		except it reports the sockets in the INET6 address family.
  *
- * Version:	$Id: proc.c,v 1.17 2002/02/01 22:01:04 davem Exp $
- *
  * Authors:	David S. Miller (davem@caip.rutgers.edu)
  * 		YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
  *
diff --git a/net/ipv6/protocol.c b/net/ipv6/protocol.c
index f929f47..9ab7891 100644
--- a/net/ipv6/protocol.c
+++ b/net/ipv6/protocol.c
@@ -5,8 +5,6 @@
  *
  *		PF_INET6 protocol dispatch tables.
  *
- * Version:	$Id: protocol.c,v 1.10 2001/05/18 02:25:49 davem Exp $
- *
  * Authors:	Pedro Roque	<roque@di.fc.ul.pt>
  *
  *		This program is free software; you can redistribute it and/or
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 232e0dc..e47775e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -7,8 +7,6 @@
  *
  *	Adapted from linux/net/ipv4/raw.c
  *
- *	$Id: raw.c,v 1.51 2002/02/01 22:01:04 davem Exp $
- *
  *	Fixes:
  *	Hideaki YOSHIFUJI	:	sin6_scope_id support
  *	YOSHIFUJI,H.@USAGI	:	raw checksum (RFC2292(bis) compliance)
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 798cabc..dcb4674 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *
- *	$Id: reassembly.c,v 1.26 2001/03/07 22:00:57 davem Exp $
- *
  *	Based on: net/ipv4/ip_fragment.c
  *
  *	This program is free software; you can redistribute it and/or
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 12bba08..6235d77 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *
- *	$Id: route.c,v 1.56 2001/10/31 21:55:55 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 5a6fab9..8f8686f 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -6,8 +6,6 @@
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *	Alexey Kuznetsov	<kuznet@ms2.inr.ac.ru>
  *
- *	$Id: sit.c,v 1.53 2001/09/25 05:09:53 davem Exp $
- *
  *	This program is free software; you can redistribute it and/or
  *      modify it under the terms of the GNU General Public License
  *      as published by the Free Software Foundation; either version
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 715965f..1554991 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -5,8 +5,6 @@
  *	Authors:
  *	Pedro Roque		<roque@di.fc.ul.pt>
  *
- *	$Id: tcp_ipv6.c,v 1.144 2002/02/01 22:01:04 davem Exp $
- *
  *	Based on:
  *	linux/net/ipv4/tcp.c
  *	linux/net/ipv4/tcp_input.c
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1fd784f..47e09c3 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -7,8 +7,6 @@
  *
  *	Based on linux/ipv4/udp.c
  *
- *	$Id: udp.c,v 1.65 2002/02/01 22:01:04 davem Exp $
- *
  *	Fixes:
  *	Hideaki YOSHIFUJI	:	sin6_scope_id support
  *	YOSHIFUJI Hideaki @USAGI and:	Support IPV6_V6ONLY socket option, which
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 491efd0..f6cdcb3 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -2,8 +2,6 @@
  *  UDPLITEv6   An implementation of the UDP-Lite protocol over IPv6.
  *              See also net/ipv4/udplite.c
  *
- *  Version:    $Id: udplite.c,v 1.9 2006/10/19 08:28:10 gerrit Exp $
- *
  *  Authors:    Gerrit Renker       <gerrit@erg.abdn.ac.uk>
  *
  *  Changes:
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2cee87d..beca640 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -5,8 +5,6 @@
  *
  *		PACKET - implements raw packet sockets.
  *
- * Version:	$Id: af_packet.c,v 1.61 2002/02/08 03:57:19 davem Exp $
- *
  * Authors:	Ross Biro
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
  *		Alan Cox, <gw4pts@gw4pts.ampr.org>
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 5bc1ed4..2130718 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -24,8 +24,6 @@
  *		Jiri Fojtasek
  *			fixed requeue routine
  *		and many others. thanks.
- *
- * $Id: sch_htb.c,v 1.25 2003/12/07 11:08:25 devik Exp devik $
  */
 #include <linux/module.h>
 #include <linux/types.h>
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index cc12d5f..019d4b4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -33,8 +33,6 @@
  *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- *
- * $Id$
  */
 
 
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index b4f0525..584357a 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -4,7 +4,6 @@
  * Begun April 1, 1996, Mike Shaver.
  * Added /proc/sys/net directories for each protocol family. [MS]
  *
- * $Log: sysctl_net.c,v $
  * Revision 1.2  1996/05/08  20:24:40  shaver
  * Added bits for NET_BRIDGE and the NET_IPV4_ARP stuff and
  * NET_IPV4_IP_FORWARD.
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e18cd36..392e80e 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -8,8 +8,6 @@
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
  *
- * Version:	$Id: af_unix.c,v 1.133 2002/02/08 03:57:19 davem Exp $
- *
  * Fixes:
  *		Linus Torvalds	:	Assorted bug cures.
  *		Niibe Yutaka	:	async I/O support.

