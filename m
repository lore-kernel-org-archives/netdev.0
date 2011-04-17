From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-rhine: do not freak out due to invalid MAC address
Date: Sat, 16 Apr 2011 17:11:16 -0700 (PDT)
Message-ID: <20110416.171116.226766123.davem@davemloft.net>
References: <4DAA12C0.7030106@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rl@hellgate.ch
To: mr.nuke.me@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42343
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751331Ab1DQALv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 20:11:51 -0400
In-Reply-To: <4DAA12C0.7030106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alex G." <mr.nuke.me@gmail.com>
Date: Sun, 17 Apr 2011 01:05:52 +0300

> via-rhine drops out of the init code if the hardware provides an invalid
> MAC address. Roger Luethi has had several reports of Rhine NICs doing just
> that. The hardware still works, though; assigning a random MAC address
> allows the NIC to be used as usual. Tested as a standalone interface,
> as carrier for ppp, and as bonding slave.
> 
> Signed-off-by: Alexandru Gagniuc <mr.nuke.me@gmail.com>

Your patch is corrupted, your email client turned tab characters
into spaces, which makes your patch unusable.

Please read Documentation/email-clients.txt to learn how to fix
this, try sending the patch to yourself and testing that you
can actually apply the patch as you receive it, and then make a
full, clean, resubmission of the fixed patch.

Thanks.
