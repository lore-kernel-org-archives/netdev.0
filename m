From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [Bug #12160] networking oops after resume from s2ram (2.6.28-rc6)
Date: Mon, 19 Jan 2009 22:45:37 +0100 (CET)
Message-ID: <cX2gZ6Cy9nC.A.PxD.lKRdJB@chimera>
References: <KTnguC9mFUC.A.VNB.TJRdJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Kernel Testers List <kernel-testers@vger.kernel.org>,
	"Marcin Slusarz" <marcin.slusarz@gmail.com>,
	"netdev" <netdev@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:40566 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762665AbZATAFB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:05:01 -0500
In-Reply-To: <KTnguC9mFUC.A.VNB.TJRdJB@chimera>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message has been generated automatically as a part of a report
of regressions introduced between 2.6.27 and 2.6.28.

The following bug entry is on the current list of known regressions
introduced between 2.6.27 and 2.6.28.  Please verify if it still should
be listed and let me know (either way).


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12160
Subject		: networking oops after resume from s2ram (2.6.28-rc6)
Submitter	: Marcin Slusarz <marcin.slusarz@gmail.com>
Date		: 2008-11-28 21:15 (53 days old)
References	: http://marc.info/?l=linux-kernel&m=122790701615723&w=4


