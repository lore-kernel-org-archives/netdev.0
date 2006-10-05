From: Michael Buesch <mb@bu3sch.de>
Subject: Please pull bcm43xx-d80211 fixes
Date: Thu, 5 Oct 2006 16:51:08 +0200
Message-ID: <200610051651.09152.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Martin Langer <martin-langer@gmx.de>,
	bcm43xx-dev@lists.berlios.de, Bandan <bandan.das@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:48817
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751472AbWJEOwC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 10:52:02 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

I updated the "for-linville" branch of my tree with one important
bugfix and a small cleanup.
In case you didn't pull, yet, this will pull all changes of my previous
pull request plus the following two.

bcm43xx-d80211: Wait for the firmware to respond, before we read revision codes.
http://bu3sch.de/gitweb?p=wireless-dev.git;a=commitdiff;h=faac518bf4a2d2846a7153b0b4f8b99ff8db4166

bcm43xx-d80211: Remove unused "err" variables.
http://bu3sch.de/gitweb?p=wireless-dev.git;a=commitdiff;h=455ae5bb4ee0b18ed06ffee0d89b92a8fca3f217


The old branch (as I submitted it in my previous pull request) is
still available for reference as "old-for-linville". But I don't think
you'll need it. Simply pull from "for-linville" now, please.

-- 
Greetings Michael.
