From: Johannes Stezenbach <js@sig21.net>
Subject: Q: netdev: generate kobject uevent on network events.
Date: Wed, 9 Dec 2009 18:02:51 +0100
Message-ID: <20091209170251.GA11650@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:60192 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753346AbZLIRCr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 12:02:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

about a year ago you posted a patch which allows to manage
network hotplug via udev (or busybox mdev), which is useful
for low-end embedded platforms that don't want to run ifplugd.

http://article.gmane.org/gmane.linux.hotplug.devel/13386

The patch still works with 2.6.32.  Can it get merged or
were there any issues with it?  It seems the discussion
just stopped and the patch was forgotten...


Johannes
