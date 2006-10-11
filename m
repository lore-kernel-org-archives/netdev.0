From: paul.moore@hp.com
Subject: [PATCH 0/3] Collection of small NetLabel bugfixes
Date: Wed, 11 Oct 2006 19:10:46 -0400
Message-ID: <20061011231046.825517000@hp.com>
Cc: jmorris@namei.org, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:39620 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1161277AbWJKXN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 19:13:59 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When doing some more testing today I ran into a few bugs, this patchset
addresses those bugs.  This patchset is backed against today's net-2.6 git
tree.

Please apply these patches for 2.6.19, thanks.

--
paul moore
linux security @ hp
