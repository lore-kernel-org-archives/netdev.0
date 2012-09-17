From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
Date: Mon, 17 Sep 2012 00:56:36 -0400 (EDT)
Message-ID: <20120917.005636.200884862654234164.davem@davemloft.net>
References: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703Ab2IQE4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 00:56:37 -0400
In-Reply-To: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 16 Sep 2012 21:15:34 -0700

>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Sigh...

You changed this tree.

It originally had the IGB PTP changes, which you asked me to
reconsider.

So I went to pull them in and now it had these new changes in
it, which I accidently pushed out to net-next instead of the
IGB stuff.

Never do this.  If you wanted me to consider to sets of
changes seperatedly, put them in seperate branches for me
to pull from.
