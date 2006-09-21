From: paul.moore@hp.com
Subject: [PATCH 0/6] NetLabel fixes and reworked Netlink interface
Date: Thu, 21 Sep 2006 12:57:03 -0400
Message-ID: <20060921165703.251871000@hp.com>
Cc: sds@epoch.ncsc.mil, jmorris@redhat.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:5538 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1751354AbWIURDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 13:03:39 -0400
To: selinux@tycho.nsa.gov, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset, made against net-2.6.19, contains a collection of fixes for bugs found over the past few weeks as well as reworked Netlink interface which should bring NetLabel more inline with common Netlink methods.  My apologies for not getting this out sooner, but the Netlink interface rewrite was a bit more involved than I originally thought.  For those wishing to test/use these patches you will need a new copy of netlabel_tools; you can get a working version from the SVN respository at http://netlabel.sf.net.

I have tested these patches and verified that they work and solve all known issues.  Please review and consider them for 2.6.19.

Thanks.

--
paul moore
linux security @ hp
