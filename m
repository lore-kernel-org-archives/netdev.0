From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] tcp: bugs and cleanup for 2.6.33
Date: Thu, 25 Feb 2010 21:33:23 -0800 (PST)
Message-ID: <20100225.213323.50363409.davem@davemloft.net>
References: <4B86DDCB.50608@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47105
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751221Ab0BZFdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 00:33:07 -0500
In-Reply-To: <4B86DDCB.50608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Thu, 25 Feb 2010 15:30:03 -0500

> I'd have thought that there would be greater interest about patching
> crashing bugs, signed versus unsigned (underflow) bugs, TCP DoS bugs,
> TCP data corruption, and TCP performance problems....

Your patches add as many bugs and problems as they claim to solve.

You also attack, in your commit messages and code coments, the
very people you want to look at your changes and integrate them.

How you hope to make forward progress in these circumstances is
beyond me.

Just remember William: Whilst people have a right to say whatever
they want, they must earn the privilege to being listened to.

And currently many people have you set strictly to ignore.
