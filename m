From: kubriel <kubriel@servus.at>
Subject: Re: [PATCH] alx: remove WoL support
Date: Wed, 2 Oct 2013 10:55:39 +0000 (UTC)
Message-ID: <loom.20131002T125141-408@post.gmane.org>
References: <1372880891-12320-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:47860 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341Ab3JBLPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Oct 2013 07:15:05 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VRKOV-0001sL-SM
	for netdev@vger.kernel.org; Wed, 02 Oct 2013 13:15:04 +0200
Received: from adsl-d227.84-47-31.t-com.sk ([84.47.31.227])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 13:15:03 +0200
Received: from kubriel by adsl-d227.84-47-31.t-com.sk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 13:15:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes <at> sipsolutions.net> writes:

> 
> Unfortunately, WoL is broken and the system will immediately
> resume after suspending, and I can't seem to figure out why.
> Remove WoL support until the issue can be found.
> 

hallo,
i was using wol feature of alx.
my only problem was, that sometimes it turn on coputer immediately after
shutdown

i can provide some help, as i have acces to this hardware on my desktop.
