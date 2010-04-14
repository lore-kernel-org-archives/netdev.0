From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL] vhost-net fix for 2.6.34-rc4
Date: Wed, 14 Apr 2010 17:17:33 +0300
Message-ID: <20100414141733.GA5370@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9920 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755501Ab0DNOVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Apr 2010 10:21:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,
The following tree includes a patch fixing an issue with vhost-net in
2.6.34-rc4.  Please pull for 2.6.34.

Thanks!

The following changes since commit 2ba3abd8186f24c7fb418927025b4e2120e3a362:

  Merge branch 'pm-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/suspend-2.6 (2010-04-13 17:49:48 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost

Christoph Hellwig (1):
      vhost: fix sparse warnings

 drivers/vhost/net.c   |    4 ++--
 drivers/vhost/vhost.c |   11 ++++++-----
 2 files changed, 8 insertions(+), 7 deletions(-)
