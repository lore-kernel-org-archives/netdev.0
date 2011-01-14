From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: net 00/05: routing based send-to-self implementation
Date: Fri, 14 Jan 2011 06:40:48 -0700
Message-ID: <20110114064048.5829220a@bike.lwn.net>
References: <20091203112550.15100.86217.sendpatchset@x2.localnet>
	<20110114101832.GA3170@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org, Boris Kocherov <bkocherov@gmail.com>
To: Kirill Smelkov <kirr@mns.spb.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tex.lwn.net ([70.33.254.29]:36216 "EHLO vena.lwn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757511Ab1ANONb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 09:13:31 -0500
In-Reply-To: <20110114101832.GA3170@tugrik.mns.mnsspb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Jan 2011 13:18:32 +0300
Kirill Smelkov <kirr@mns.spb.ru> wrote:

>  ( Jonathan, I though something like this could be useful for LDD4 in
>    revised snull not needing to play dirty tricks with IP addresses anymore )

Nice thought, thanks.  I don't know yet whether we'd want to do that or
just run stuff on a virtual machine for LDD4 - lots of stuff to figure
out still.

Thanks,

jon
