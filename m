From: paul.moore@hp.com
Subject: [PATCH 0/6] Various NetLabel fixes and cleanups
Date: Tue, 29 Aug 2006 10:42:51 -0400
Message-ID: <20060829144251.452774000@hp.com>
Cc: jmorris@namei.org, sds@tycho.nsa.gov, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:43142 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S965007AbWH2Oor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 10:44:47 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset contains a series of small patches to fix a bug and some general
ugliness from the original author (that moron ...).  All of the following
patches are against David's net-2.6.19 tree.

Please consider these for 2.6.19, thanks.

--
paul moore
linux security @ hp
