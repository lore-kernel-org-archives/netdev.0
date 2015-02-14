From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] net: spelling fixes
Date: Sat, 14 Feb 2015 13:47:54 -0500
Message-ID: <20150214134754.07a6aed8@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:37763 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754181AbbBNSr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 13:47:57 -0500
Received: by iecrl12 with SMTP id rl12so24014470iec.4
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 10:47:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spelling errors caught by codespell.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/core/filter.c	2015-02-14 13:43:49.650827618 -0500
+++ b/net/core/filter.c	2015-02-14 13:43:49.646827774 -0500
@@ -531,7 +531,7 @@ do_pass:
 			*insn = BPF_LDX_MEM(BPF_W, BPF_REG_A, BPF_REG_CTX, fp->k);
 			break;
 
-		/* Unkown instruction. */
+		/* Unknown instruction. */
 		default:
 			goto err;
 		}
--- a/net/core/pktgen.c	2015-02-14 13:43:49.650827618 -0500
+++ b/net/core/pktgen.c	2015-02-14 13:43:49.650827618 -0500
@@ -97,7 +97,7 @@
  * New xmit() return, do_div and misc clean up by Stephen Hemminger
  * <shemminger@osdl.org> 040923
  *
- * Randy Dunlap fixed u64 printk compiler waring
+ * Randy Dunlap fixed u64 printk compiler warning
  *
  * Remove FCS from BW calculation.  Lennert Buytenhek <buytenh@wantstofly.org>
  * New time handling. Lennert Buytenhek <buytenh@wantstofly.org> 041213
--- a/net/ipv4/devinet.c	2015-02-14 13:43:49.650827618 -0500
+++ b/net/ipv4/devinet.c	2015-02-14 13:43:49.650827618 -0500
@@ -1186,7 +1186,7 @@ __be32 inet_select_addr(const struct net
 no_in_dev:
 
 	/* Not loopback addresses on loopback should be preferred
-	   in this case. It is importnat that lo is the first interface
+	   in this case. It is important that lo is the first interface
 	   in dev_base list.
 	 */
 	for_each_netdev_rcu(net, dev) {
