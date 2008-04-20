From: David Miller <davem@davemloft.net>
Subject: Re: [build bug] drivers/built-in.o: In function
 `rt2x00leds_resume': : undefined reference to `led_classdev_resume'
Date: Sun, 20 Apr 2008 01:54:04 -0700 (PDT)
Message-ID: <20080420.015404.86827224.davem@davemloft.net>
References: <20080420081302.GA11954@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, tomas.winkler@intel.com,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	mabbas@linux.intel.com, ischram@telenet.be, rjw@sisk.pl,
	ivdoorn@gmail.com
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57340
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752093AbYDTIyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 04:54:04 -0400
In-Reply-To: <20080420081302.GA11954@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Sun, 20 Apr 2008 10:13:02 +0200

> Really, your practice of removing networking commits and pull
> requests from lkml does not result in a stellar quality track
> record.

Ingo I started posting them the way you asked me to today.
Because everyone must do as Ingo says or else he'll berate
them on the list every day.

So please, just drop it already.  You got what you wanted.

FWIW, all of the patches in question were posted to netdev and
linux-wireless.  And I already explained my original logic for not
posting the huge networking merge pull request, it's too damn large
(128K or so) to be useful at all and will result in tons of bounces
(which I have to process btw)

But even with all that, I'm doing it now Ingo, just to make you quiet.

So just LEAVE ME ALONE already!
