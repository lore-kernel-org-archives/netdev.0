From: Christine Caulfield <christine.caulfield@googlemail.com>
Subject: [PATCH] Orphan DECnet
Date: Thu, 18 Feb 2010 11:33:13 +0000
Message-ID: <1266492793.412.1.camel@rhdesktop.chrissie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, torvalds@linux-foundation.org,
	swhiteho@redhat.com, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from queueout01-winn.ispmail.ntl.com ([81.103.221.31]:24453 "EHLO
	queueout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752374Ab0BRLqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 06:46:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hiya all

Due to lack of time, space, motivation, hardware and probably expertise,
I have reluctantly decided to orphan the DECnet code in the kernel.

Judging by the deafening silence on the linux-decnet mailing list I
suspect it's either not being used anyway, or the few people that are
using it are happy with their older kernels.

Chrissie


Signed-Off-By: Christine Caulfield <christine.caulfield@googlemail.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 412eff6..8ed3d0a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1733,10 +1733,9 @@ F:	include/linux/tfrc.h
 F:	net/dccp/
 
 DECnet NETWORK LAYER
-M:	Christine Caulfield <christine.caulfield@googlemail.com>
 W:	http://linux-decnet.sourceforge.net
 L:	linux-decnet-user@lists.sourceforge.net
-S:	Maintained
+S:	Orphan
 F:	Documentation/networking/decnet.txt
 F:	net/decnet/
 


