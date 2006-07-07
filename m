From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth update for 2.6
Date: Sat, 08 Jul 2006 00:54:30 +0200
Message-ID: <1152312870.3693.24.camel@localhost>
References: <1152216560.20938.37.camel@localhost>
	 <20060707.001745.07431025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:59306 "EHLO
	mail.holtmann.net") by vger.kernel.org with ESMTP id S932244AbWGGWy0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 18:54:26 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060707.001745.07431025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> > this is the second part of pending updates of the Bluetooth subsystem
> > for the upcoming 2.6.18 kernel. A couple of them are only coding style
> > cleanups which I failed to submit for the previous kernel release. They
> > slipped somehow. The rest is driver model integration stuff. Please push
> > them to Linus as soon as possible.
> 
> The merge window for 2.6.18 is closed, so you will need to eliminate
> things like code cleanups and other non-bugfixes.

yes, I saw that, but actually these patches were meant to get to you
before the merge window closed. I failed to prepare the tree, because I
lost remote access to one of my machines were I unfortunately had queued
all of these patches. Do you think Linus will make an exception?

Regards

Marcel


