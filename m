From: paul.moore@hp.com
Subject: [PATCH 00/13] NetLabel cleanups for 2.6.20
Date: Fri, 17 Nov 2006 17:38:42 -0500
Message-ID: <20061117223842.399078000@hp.com>
Cc: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:47769 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1755986AbWKQWne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 17:43:34 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset consists of a lot of small-ish cleanups for NetLabel and in some
cases labeled networking in general.  I've tested these patches for the past
few days and I haven't seen any regressions so please consider them for the
net-2.6.20 git tree.

The patches are fairly varied so it doesn't make sense to go into too much
details here, please see each patch for an explanation of what it does.

--
paul moore
linux security @ hp
