From: paul.moore@hp.com
Subject: [PATCH v2 0/8] Updated patchset with Thomas' comments
Date: Mon, 25 Sep 2006 14:04:12 -0400
Message-ID: <20060925180412.715069000@hp.com>
Cc: tgraf@suug.ch, jmorris@redhat.com, sds@epoch.ncsc.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:33211 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1751421AbWIYSGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 14:06:43 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an updated patchset which takes into account Thomas' comments.  This
includes the addition of two new patches in the patchset which add a new
Netlink interface as well as correct the list of interfaces in the large
comment block at the top of include/net/netlink.h.

Please consider these patches for 2.6.19, thanks.

--
paul moore
linux security @ hp
