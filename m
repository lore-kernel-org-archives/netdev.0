From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 14594] New: ISDN-B-channel-bundling broken
Date: Sun, 15 Nov 2009 22:23:27 -0800 (PST)
Message-ID: <20091115.222327.61827479.davem@davemloft.net>
References: <bug-14594-10822@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bugzilla-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55875
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752003AbZKPGXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 01:23:11 -0500
In-Reply-To: <bug-14594-10822@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: bugzilla-daemon@bugzilla.kernel.org
Date: Fri, 13 Nov 2009 17:21:21 GMT

> This bug is present since since kernel 2.6.28 (2.6.27-rc6) and has been
> introduced with
> 
> commit 38783e671399b5405f1fd177d602c400a9577ae6
> Author: David S. Miller <davem@davemloft.net>
> Date:   Mon Sep 22 01:15:02 2008 -0700
> 
>     isdn: isdn_ppp: Use SKB list facilities instead of home-grown
> implementation.

I'll revert this, thanks.
