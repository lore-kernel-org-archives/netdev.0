From: Phil Sutter <phil@nwl.cc>
Subject: Re: Sending IPv6 packets broken in net-next
Date: Thu, 16 Jul 2015 09:47:19 +0200
Message-ID: <20150716074719.GA14916@orbit.nwl.cc>
References: <20150715222046.GE14670@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org,
	YOSHIFUJI =?utf-8?B?SGlkZWFraS/lkInol6Toi7HmmI4=?=
	<hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:59803 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752468AbbGPHrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 03:47:21 -0400
Content-Disposition: inline
In-Reply-To: <20150715222046.GE14670@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2015 at 12:20:46AM +0200, Phil Sutter wrote:
> Commit 9131f3d ("ipv6: Do not iterate over all interfaces when finding
> source address on specific interface") breaks local output of IPv6
> packets. Here is a simple reproducer:

I just noticed, a patch fixing the issue has already been sent to this
list[1]. So nevermind and sorry for the traffic!

Cheers, Phil

[1]: http://www.spinics.net/lists/netdev/msg335586.html
