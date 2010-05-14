From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 14 May 2010 04:06:21 -0700 (PDT)
Message-ID: <20100514.040621.232882257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58939
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754563Ab0ENLGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 07:06:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


One small last minute fix from the VHOST folks to deal with some
memory barrier issues.

Please pull, thanks a lot!

The following changes since commit cea0d767c29669bf89f86e4aee46ef462d2ebae8:
  Linus Torvalds (1):
        Merge branch 'hwmon-for-linus' of git://git.kernel.org/.../jdelvare/staging

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      Merge branch 'net-2.6' of git://git.kernel.org/.../mst/vhost

Michael S. Tsirkin (1):
      vhost: fix barrier pairing

 drivers/vhost/vhost.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)
