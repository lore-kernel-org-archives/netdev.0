From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [GIT PULL] vhost-net fix for 2.6.34-rc3
Date: Wed, 7 Apr 2010 20:35:02 +0300
Message-ID: <20100407173502.GA26061@redhat.com>
References: <20100318095355.GA24194@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Dike <jdike@linux.intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7726 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753270Ab0DGRiy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Apr 2010 13:38:54 -0400
Content-Disposition: inline
In-Reply-To: <20100318095355.GA24194@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,
The following tree includes a patch fixing an issue with vhost-net in
2.6.34-rc3.  Please pull for 2.6.34.
 
Thanks!

The following changes since commit 2eaa9cfdf33b8d7fb7aff27792192e0019ae8fc6:

  Linux 2.6.34-rc3 (2010-03-30 09:24:39 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost

Jeff Dike (1):
      vhost-net: fix vq_memory_access_ok error checking

 drivers/vhost/vhost.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)
