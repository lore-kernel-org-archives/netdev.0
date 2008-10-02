From: Greg KH <greg@kroah.com>
Subject: atl2 network driver status
Date: Thu, 2 Oct 2008 16:02:46 -0700
Message-ID: <20081002230246.GA11570@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xiong.huang@atheros.com, csnook@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:41035 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752596AbYJBXFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 19:05:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In looking for drivers to add to drivers/staging/ I ran across the atl2
driver that is currently in the Fedora and Ubuntu kernel trees.

This driver doesn't look to be scheduled for inclusion in the upstream
netdev git tree for submission for 2.6.28, is there any reason why it is
still out-of-the-tree?

And, if it's not going into 2.6.28, any objection for me adding it to
the drivers/staging/ tree?  If so, I need a list of reasons why it is
not merged upstream properly so far so that people know what to work on
in order to get it there.

thanks,

greg k-h
