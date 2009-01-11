From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [Bug #12160] networking oops after resume from s2ram (2.6.28-rc6)
Date: Sun, 11 Jan 2009 12:41:01 +0100 (CET)
Message-ID: <nHCfeC0YLrE.A.xMD.hbfaJB@chimera>
References: <nn3SOLVZ28H.A.bY.CafaJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Kernel Testers List <kernel-testers@vger.kernel.org>,
	"Marcin Slusarz" <marcin.slusarz@gmail.com>,
	"netdev" <netdev@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:36814 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752932AbZAKN5o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 08:57:44 -0500
In-Reply-To: <nn3SOLVZ28H.A.bY.CafaJB@chimera>
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
Date		: 2008-11-28 21:15 (45 days old)
References	: http://marc.info/?l=linux-kernel&m=122790701615723&w=4


