From: David Miller <davem@davemloft.net>
Subject: Re: READ ME, net-2.6 fully merged
Date: Sat, 19 Jul 2008 01:01:30 -0700 (PDT)
Message-ID: <20080719.010130.75931447.davem@davemloft.net>
References: <20080718.033947.193705552.davem@davemloft.net>
	<48819CCC.8070800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59204
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751680AbYGSIBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 04:01:30 -0400
In-Reply-To: <48819CCC.8070800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 19 Jul 2008 09:50:36 +0200

> A little btw. question: I know you are busy now with more serious
> problems and it's not for now, but: after the last net-next-2.6 git
> policy change most of the time neither net-2.6 nor net-next-2.6
> could be treated as current net state. I tried to stick to net-next,
> but it was idle most of the time.

I don't want to merge too much, but I did merge net-2.6 into
net-next-2.6 periodically.

Basically my main impetus to merge is when I know or sense that merge
conflicts are building up.

I would recommend that people work on the tree that is appropriate
for the work they are doing.  And outside of a merge window that
means net-2.6 for a bug fix and net-next-2.6 for new work (or bug
fixes to new work).

Inside of the merge window, like we are now, will have everything
going into net-2.6
