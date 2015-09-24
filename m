From: David Miller <davem@davemloft.net>
Subject: Re: [Linux 4.2-rc8+...v4.3-rc2] REGRESSION: ppp: circular locking
 dependency detected: [pppd] ppp_dev_uninit() | rtnl_lock()
Date: Thu, 24 Sep 2015 11:00:55 -0700 (PDT)
Message-ID: <20150924.110055.1257680342513050032.davem@davemloft.net>
References: <CA+icZUU0rUJZRb4R+F1N98hbfb0rbmbZ0=Jf60zb30SQHKi1Ug@mail.gmail.com>
	<20150924110317.GF2869@alphalink.fr>
	<CA+icZUUcmjxNsMDHuWY9zi9RSBum7hR=HWmWfxs=swRbqm4p7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: g.nault@alphalink.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sedat.dilek@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174AbbIXSA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 14:00:57 -0400
In-Reply-To: <CA+icZUUcmjxNsMDHuWY9zi9RSBum7hR=HWmWfxs=swRbqm4p7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Thu, 24 Sep 2015 18:19:16 +0200

> OK, I guess DaveM will take your patch into net.git#master first...
> and tag it there with CC-stable?

I do not tag anything with stable.

I queue it up into a patchwork bundle and explicitly submit those
patches to stable@vger.kernel.org at a time of my own choosing.

This is a FAQ, documented in the kernel Documentation/ subdirectory.
