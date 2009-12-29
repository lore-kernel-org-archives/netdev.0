From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [Bug #14925] sky2 panic under load
Date: Tue, 29 Dec 2009 16:10:00 +0100 (CET)
Message-ID: <NJVdobuNFNK.A.k-G.PnhOLB__49686.5475005054$1262099948$gmane$org@chimera>
References: <LptzGUUXbTK.A.MSF.ymhOLB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Kernel Testers List <kernel-testers@vger.kernel.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"Berck Nash" <flyboy@gmail.com>,
	"Daniel Hazelton" <dhazelton@enter.net>,
	"Michael Breuer" <mbreuer@majjas.com>,
	"netdev@vger.kernel.org"@ogre.sisk.pl,
	"Stephen Hemminger" <shemminger@vyatta.com>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:38984 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783AbZL2POh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 10:14:37 -0500
In-Reply-To: <LptzGUUXbTK.A.MSF.ymhOLB@chimera>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This message has been generated automatically as a part of a report
of recent regressions.

The following bug entry is on the current list of known regressions
from 2.6.32.  Please verify if it still should be listed and let me know
(either way).


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=14925
Subject		: sky2 panic under load
Submitter	: Berck E. Nash <flyboy@gmail.com>
Date		: 2009-12-21 23:52 (9 days old)
References	: http://marc.info/?l=linux-kernel&m=126143955730347&w=4
		  http://marc.info/?l=linux-kernel&m=126160893126548&w=4
Handled-By	: Stephen Hemminger <shemminger@vyatta.com>


