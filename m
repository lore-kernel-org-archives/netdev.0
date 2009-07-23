From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13760] New: 2.6.30 kernel locks up with pppoe
 in back trace (regression)
Date: Thu, 23 Jul 2009 09:14:24 -0700 (PDT)
Message-ID: <20090723.091424.27847831.davem@davemloft.net>
References: <bug-13760-10286@http.bugzilla.kernel.org/>
	<20090722134557.2457c5f5.akpm@linux-foundation.org>
	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: for.poige+bugzilla.kernel.org@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51921
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754395AbZGWQOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 12:14:18 -0400
In-Reply-To: <43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>
Date: Thu, 23 Jul 2009 14:39:29 +0800

> 	Just repeating the same thing I had written in the Bugzilla: I
> haven't noticed any changes to pppoe during last commits to 2.6.30.
> Why do you think there's a chance that bug(s) would have been fixed?

There were TTY layer changes that have an effect on PPP and
the like.
