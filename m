From: paul.moore@hp.com
Subject: [PATCH 0/2] [PATCH 0/2] Updated NetLabel/secid-reconciliation bits and a bugfix
Date: Wed, 04 Oct 2006 11:46:29 -0400
Message-ID: <20061004154629.186531000@hp.com>
Cc: eparis@redhat.com, jmorris@namei.org, sds@tycho.nsa.gov,
	vyekkirala@TrustedCS.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:32473 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1161253AbWJDPsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 11:48:14 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset includes an update to the NetLabel/secid-reconciliation patch,
replacing my "v3" patch from earlier this week, and a bugfix patch to cure a
race condition found during testing this week.  The bugfix patch does not
rely on the secid patches and should be merged regardless as it fixes a bug
which has been around since the very first NetLabel patches (not sure why I
didn't see this sooner).

--
paul moore
linux security @ hp

