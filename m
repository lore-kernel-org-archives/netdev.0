From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: send NEWLINK on RA managed/otherconf changes
Date: Mon, 31 Aug 2015 16:50:34 -0700 (PDT)
Message-ID: <20150831.165034.1315157458091096557.davem@davemloft.net>
References: <20150831135922.GA24179@suse.de>
	<20150831.151351.228280334434841531.davem@davemloft.net>
	<55E4E6AB.4040108@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mt@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601AbbHaXuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 19:50:37 -0400
In-Reply-To: <55E4E6AB.4040108@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marius Tomaschewski <mt@suse.de>
Date: Tue, 1 Sep 2015 01:43:39 +0200

> I've attached a follow-up patch doing this. Please let me know if you
> need it in a separate mail.

I want it in a separate mail, and please use "bool" for the type.
