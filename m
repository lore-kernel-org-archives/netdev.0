From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: Heads up: additional work on SELinux xfrm
Date: Mon, 12 Jun 2006 12:47:45 -0400
Message-ID: <36282A1733C57546BE392885C0618592012D6397@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Chad Hanson <chanson@TrustedCS.com>,
	Darrel Goeddel <DGoeddel@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:42905 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750787AbWFLQsA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 12:48:00 -0400
Received: (from smmsp@localhost)
	by tcsfw4.tcs-sec.com (8.12.2/8.12.2) id k5CGlxm3015543
	for <netdev@vger.kernel.org>; Mon, 12 Jun 2006 12:47:59 -0400 (EDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This is just a heads up for anyone interested that I have submitted a patch
set that involves core networking and the xfrm subsystem to the selinux
list. I plan on submitting it to this list as soon as it gets properly
reviewed on the SELinux side.

I am shooting for the 2.6.18 window.

Broad description/overview of changes at:
http://marc.theaimsgroup.com/?l=selinux&m=115012769919108&w=2

Core networking changes at:
http://marc.theaimsgroup.com/?l=selinux&m=115012770004292&w=2

xfrm subsystem changes at:
http://marc.theaimsgroup.com/?l=selinux&m=115012769903910&w=2

Thanks,

venkat
