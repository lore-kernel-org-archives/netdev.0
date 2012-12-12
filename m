From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: fix tc ematch manpage section
Date: Wed, 12 Dec 2012 12:23:48 +0100
Message-ID: <20121212112348.GA6520@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b31.telenor.se ([213.150.131.20]:60459 "EHLO
	smtprelay-b31.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab2LLLtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 06:49:12 -0500
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-b31.telenor.se (Postfix) with ESMTP id 3C0D0EAC85
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 12:23:50 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The debian package checking tool, lintian, spotted that the
tc ematch manpage seems to have an error in the specified section.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

diff --git a/man/man8/tc-ematch.8 b/man/man8/tc-ematch.8
index 2eafc29..957a22e 100644
--- a/man/man8/tc-ematch.8
+++ b/man/man8/tc-ematch.8
@@ -1,4 +1,4 @@
-.TH filter ematch "6 August 2012" iproute2 Linux
+.TH ematch 8 "6 August 2012" iproute2 Linux
 .
 .SH NAME
 ematch \- extended matches for use with "basic" or "flow" filters
