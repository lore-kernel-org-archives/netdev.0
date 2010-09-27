From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL net-2.6] vhost-net: last minute fix
Date: Mon, 27 Sep 2010 15:34:13 +0200
Message-ID: <20100927133411.GA4033@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1027 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755067Ab0I0Nk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Sep 2010 09:40:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,
The following tree includes a last minute bugfix for vhost-net.
It is on top of net-2.6.  Please merge it for 2.6.36.
Thanks!

The following changes since commit 2cc6d2bf3d6195fabcf0febc192c01f99519a8f3:

  ipv6: add a missing unregister_pernet_subsys call (2010-09-26 19:09:25 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net

Michael S. Tsirkin (1):
      vhost: fix log ctx signalling

 drivers/vhost/vhost.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)
