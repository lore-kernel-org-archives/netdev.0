From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 4/4] net: port mirroring: Add maintainer
Date: Tue, 15 Dec 2009 11:54:47 -0500
Message-ID: <20091215165447.GA20644@hmsreliant.think-freely.org>
References: <20091215162956.GB18710@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51205 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760595AbZLOQyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 11:54:49 -0500
Content-Disposition: inline
In-Reply-To: <20091215162956.GB18710@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add myself as maintainer for port mirroring.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index ea781c1..3f73a90 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3737,6 +3737,14 @@ S:	Maintained
 W:	https://fedorahosted.org/dropwatch/
 F:	net/core/drop_monitor.c
 
+NETWORK PORT MIRRORING
+M:	Neil Horman <nhorman@tuxdriver.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	net/core/mirror.c
+F:	include/linux/portmirror.h
+F:	net/core/net-sysfs.c
+
 NETWORKING [GENERAL]
 M:	"David S. Miller" <davem@davemloft.net>
 L:	netdev@vger.kernel.org
