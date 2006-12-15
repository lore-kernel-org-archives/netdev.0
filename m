From: paul.moore@hp.com
Subject: [PATCH 0/2] A bugfix patchset for NetLabel
Date: Fri, 15 Dec 2006 16:49:26 -0500
Message-ID: <20061215214926.018950000@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:56653 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965241AbWLOWDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 17:03:30 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set fixes two bugs that were found recently when adding new CIPSOv4
DOI definitions.  These patches are pretty small and have been tested by a few
different people on several different platforms.

Please apply these for 2.6.20 and they should probably be pushed to the 2.6.19
stable tree as well; is there anything special I need to do for that?

--
paul moore
linux security @ hp
