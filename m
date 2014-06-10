From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: filter: add test_bpf module under MAINTAINERS' networking section
Date: Tue, 10 Jun 2014 12:31:10 +0200
Message-ID: <1402396270-9726-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@plumgrid.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751144AbaFJKbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2014 06:31:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add lib/test_bpf.c entry to maintainers file under networking.
All changes were posted via netdev for review, so make sure
other people Cc it as well when they call get_maintainer.pl.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 MAINTAINERS | 1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7a06ea4..05dafe1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6130,6 +6130,7 @@ F:	include/uapi/linux/netdevice.h
 F:	tools/net/
 F:	tools/testing/selftests/net/
 F:	lib/random32.c
+F:	lib/test_bpf.c
 
 NETWORKING [IPv4/IPv6]
 M:	"David S. Miller" <davem@davemloft.net>
-- 
1.7.11.7
