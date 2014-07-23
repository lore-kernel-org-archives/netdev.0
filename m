From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 2/2] bpf: update MAINTAINERS entry
Date: Tue, 22 Jul 2014 23:01:59 -0700
Message-ID: <1406095319-3627-3-git-send-email-ast@plumgrid.com>
References: <1406095319-3627-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36287 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbaGWGCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 02:02:13 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so1048094pad.35
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 23:02:13 -0700 (PDT)
In-Reply-To: <1406095319-3627-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 MAINTAINERS |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 78215a5dea28..62bf15f6954f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1912,6 +1912,13 @@ S:	Supported
 F:	drivers/net/bonding/
 F:	include/uapi/linux/if_bonding.h
 
+BPF (Safe dynamic programs and tools)
+M:	Alexei Starovoitov <ast@kernel.org>
+L:	netdev@vger.kernel.org
+L:	linux-kernel@vger.kernel.org
+S:	Supported
+F:	kernel/bpf/
+
 BROADCOM B44 10/100 ETHERNET DRIVER
 M:	Gary Zambrano <zambrano@broadcom.com>
 L:	netdev@vger.kernel.org
-- 
1.7.9.5
